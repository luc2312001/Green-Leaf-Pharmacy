import { createContext, useContext, useEffect, useState } from "react";
import PropTypes from "prop-types";
import api from "../api/axiosInstance.js";

const AuthContext = createContext();
export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    // ⬇⬇⬇ Load lại user từ localStorage khi refresh
    const [user, setUser] = useState(() => {
        const saved = localStorage.getItem("user");

        // Không parse khi data không phải JSON hợp lệ
        if (!saved || saved === "undefined" || saved === "null") {
            return null;
        }

        try {
            return JSON.parse(saved);
        } catch (e) {
            console.error("Invalid JSON in localStorage user", e);
            return null;
        }
    });


    const [loading, setLoading] = useState(true);
    const [isAuthenticated, setIsAuthenticated] = useState(() => {
        return !!localStorage.getItem("token");
    });

    const login = async (email, password) => {
        try {
            const res = await api.post("/auth/login", { email, password });

            const { token, user } = res.data;

            // lưu token
            localStorage.setItem("token", token);

            // lưu user
            localStorage.setItem("user", JSON.stringify(user));
            setUser(user);

            setIsAuthenticated(true);

            return true;
        } catch (err) {
            console.error("Login error:", err);
            return false;
        }
    };

    const logout = () => {
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        setUser(null);
        setIsAuthenticated(false);
    };

    // verify token khi reload trang
    useEffect(() => {
        const verify = async () => {
            const token = localStorage.getItem("token");
            if (!token) {
                setLoading(false);
                return;
            }

            try {
                const res = await api.get("/auth/verifySession", {
                    headers: { Authorization: `Bearer ${token}` },
                });

                // cập nhật user
                localStorage.setItem("user", JSON.stringify(res.data.user));
                setUser(res.data.user);
                setIsAuthenticated(true);
            } catch (err) {
                console.error("Verify session error:", err);
                logout();
            }

            setLoading(false);
        };

        verify();
    }, []);

    return (
        <AuthContext.Provider
            value={{ user, login, logout, isAuthenticated, loading }}
        >
            {children}
        </AuthContext.Provider>
    );
};

AuthProvider.propTypes = {
    children: PropTypes.node.isRequired,
};
