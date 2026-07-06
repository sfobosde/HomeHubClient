import apiClient from "./ApiClient.js";

export async function getHealth() {
    const response = await apiClient.get("/health");
    return response.ok;
}