"""On-demand OpenStreetMap/OSRM routing with an offline distance fallback."""
from __future__ import annotations

from datetime import datetime, timedelta
from math import asin, cos, radians, sin, sqrt
from time import monotonic
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import json
import os

_geocode_cache: dict[str, tuple[float, tuple[float, float]]] = {}
_CACHE_SECONDS = 24 * 60 * 60
_USER_AGENT = os.getenv("ROUTING_USER_AGENT", "FleetFlow/1.0 (local development)")


def _traffic_estimate(duration_minutes: int) -> dict:
    """A transparent local estimate; public OSRM has no live traffic feed."""
    hour = datetime.now().hour
    if 8 <= hour < 11 or 17 <= hour < 21:
        level, multiplier = "High", 0.30
    elif 7 <= hour < 8 or 11 <= hour < 17 or 21 <= hour < 22:
        level, multiplier = "Moderate", 0.12
    else:
        level, multiplier = "Low", 0.03
    delay = round(duration_minutes * multiplier)
    return {"traffic_level": level, "traffic_delay_minutes": delay, "adjusted_duration_minutes": duration_minutes + delay}


def _json(url: str) -> object:
    request = Request(url, headers={"User-Agent": _USER_AGENT, "Accept": "application/json"})
    with urlopen(request, timeout=8) as response:  # nosec B310 - fixed service URLs below
        return json.loads(response.read().decode("utf-8"))


def geocode(place: str) -> tuple[float, float]:
    cached = _geocode_cache.get(place.casefold())
    if cached and monotonic() - cached[0] < _CACHE_SECONDS:
        return cached[1]
    query = urlencode({"q": place, "format": "jsonv2", "limit": 1})
    results = _json(f"https://nominatim.openstreetmap.org/search?{query}")
    if not results:
        raise ValueError(f"Location not found: {place}")
    location = results[0]
    coordinates = (float(location["lat"]), float(location["lon"]))
    _geocode_cache[place.casefold()] = (monotonic(), coordinates)
    return coordinates


def _straight_line_km(origin: tuple[float, float], destination: tuple[float, float]) -> float:
    lat1, lon1, lat2, lon2 = map(radians, (*origin, *destination))
    delta_lat, delta_lon = lat2 - lat1, lon2 - lon1
    value = sin(delta_lat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(delta_lon / 2) ** 2
    return 6371.0088 * 2 * asin(sqrt(value))


def build_route(start: str, end: str, route_type: str = "Fastest Route") -> dict:
    origin, destination = geocode(start), geocode(end)
    coordinates = f"{origin[1]},{origin[0]};{destination[1]},{destination[0]}"
    try:
        payload = _json(f"https://router.project-osrm.org/route/v1/driving/{coordinates}?overview=full&geometries=geojson&alternatives=true")
        route = payload["routes"][0]
        distance_km = round(route["distance"] / 1000, 2)
        duration_minutes = round(route["duration"] / 60)
        details = _traffic_estimate(duration_minutes)
        adjusted_duration = details["adjusted_duration_minutes"]
        return {"source_coordinates": origin, "destination_coordinates": destination, "distance_km": distance_km, "duration_minutes": duration_minutes, "eta": (datetime.utcnow() + timedelta(minutes=adjusted_duration)).isoformat(), "geometry": route["geometry"], "route_type": route_type, "fallback": False, "toll_gates_estimate": max(0, round(distance_km / 120)), **details}
    except Exception:
        distance_km = round(_straight_line_km(origin, destination), 2)
        duration_minutes = max(1, round(distance_km / 45 * 60))
        details = _traffic_estimate(duration_minutes)
        adjusted_duration = details["adjusted_duration_minutes"]
        return {"source_coordinates": origin, "destination_coordinates": destination, "distance_km": distance_km, "duration_minutes": duration_minutes, "eta": (datetime.utcnow() + timedelta(minutes=adjusted_duration)).isoformat(), "geometry": {"type": "LineString", "coordinates": [[origin[1], origin[0]], [destination[1], destination[0]]]}, "route_type": route_type, "fallback": True, "toll_gates_estimate": max(0, round(distance_km / 120)), **details}
