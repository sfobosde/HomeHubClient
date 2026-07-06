import apiClient from "./ApiClient";

export async function getHealth() {
    const response = await apiClient.get("/health");
    return response.ok;
}