import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "../components/Login";
import Home from "../components/Home";
import RegisterPage from "@/components/RegisterPage";
import Dashboard from "@/components/Dashboard";
import AdminLayout from "@/components/AdminLayout";
import Users from "@/components/UserPage";
import Product from "@/components/productPage";
import ProductDetailPage from "@/components/productDetail";


export default function AppRoutes() {
    return (
        <BrowserRouter>

            <Routes>
                <Route path="/admin" element={<AdminLayout />}>
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="users" element={<Users />} />
                </Route>
                <Route path="/" element={<Login />} />
                <Route path="/login" element={<Login />} />
                <Route path="/home" element={<Home />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/products" element={<Product />} />
                <Route path="/product-detail/:id" element={<ProductDetailPage />} />
            </Routes>

        </BrowserRouter>
    );
}
