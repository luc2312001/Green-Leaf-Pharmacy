import PropTypes from "prop-types";
import { Navigate } from "react-router-dom";
import { useAuth } from "../AuthContext/AuthContext";

export default function ProtectedRoute({ children }) {
    const { user } = useAuth();

    if (!user) return <Navigate to="/login" replace />;

    return children;
}

ProtectedRoute.propTypes = {
    children: PropTypes.node.isRequired,
};
