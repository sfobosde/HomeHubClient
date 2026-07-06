class ApiClient {
    constructor() {
        this.baseUrl = "/api";
    }

    async request(url, options = {}) {
        const response = await fetch(`${this.baseUrl}${url}`, {
            headers: {
                "Content-Type": "application/json",
                ...options.headers
            },
            ...options
        });

        if (response.status === 401) {
            console.log("User unauthorized.");

        }
        if (!response.ok) {
            throw new Error(response.statusText);
        }
        return response;
    }

    get(url) {
        return this.request(url);
    }

    post(url, body) {
        return this.request(url, {
            method: "POST",
            body: JSON.stringify(body)
        });
    }
}

export default new ApiClient();