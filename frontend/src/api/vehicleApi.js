import api from "./axios";

export const getVehicles = async () => {
  const response = await api.get("/vehicles/");
  return response.data;
};

export const createVehicle = async (vehicle) => {
  const response = await api.post("/vehicles/", vehicle);
  return response.data;
};

export const updateVehicle = async (id, vehicle) => {
  const response = await api.put(`/vehicles/${id}`, vehicle);
  return response.data;
};

export const deleteVehicle = async (id) => {
  const response = await api.delete(`/vehicles/${id}`);
  return response.data;
};