
import Sidebar from "./Sidebar";
import ProtectedRoute from "./ProtectedRoute";
export default function AdminLayout() {
    return (
        <div style={{ height: "100vh", width: "100vw" }}>
            <ProtectedRoute>
                <Sidebar />
            </ProtectedRoute>
        </div>
    );
}
