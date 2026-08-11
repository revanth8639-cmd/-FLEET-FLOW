import api from "./axios";

export const getShipments = async () => {
  const response = await api.get("/shipments/");
  return response.data;
};

export const createShipment = async (shipment) => {
  const response = await api.post("/shipments/", shipment);
  return response.data;
};

export const updateShipment = async (id, shipment) => {
  const response = await api.put(`/shipments/${id}`, shipment);
  return response.data;
};

export const deleteShipment = async (id) => {
  const response = await api.delete(`/shipments/${id}`);
  return response.data;
};