import { useEffect, useState } from "react";
import { getHealth } from "../api/HealtApi.js";

function HomePage() {
    const [status, setStatus] = useState("Checking...");
    useEffect(() => {
        getHealth()
            .then(() => setStatus("Healthy"))
            .catch(() => setStatus("Offline"));
    }, []);
    return (
        <div>
            <h1>HomeHub</h1>
            <p>
                Backend State:
                <b> {status}</b>
            </p>
        </div>
    );
}

export default HomePage;