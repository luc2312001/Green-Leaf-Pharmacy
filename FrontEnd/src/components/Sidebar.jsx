import { useState } from 'react';
import { NavLink } from "react-router-dom";
import { useNavigate } from 'react-router-dom';
import { Outlet } from 'react-router-dom';
import { useAuth } from '@/AuthContext/AuthContext';
import {
    Home,
    Users,
    ShoppingBag,
    Bell,
    Search,
    Menu,
    X,
    ChevronDown,
    LogOut,
    User
} from 'lucide-react';
export default function Sidebar() {
    const navigate = useNavigate();
    const { user, logout } = useAuth();
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [isProfileOpen, setIsProfileOpen] = useState(false);
    const handleLogout = () => {
        logout();           // clear token + user trong AuthContext
        navigate("/login"); // chuyển về trang login
    };
    const menuItems = [
        { id: 'dashboard', icon: Home, label: 'Dashboard', badge: null, url: "http://localhost:5173/admin/dashboard" },
        { id: 'users', icon: Users, label: 'Người dùng', badge: null, url: "http://localhost:5173/admin/users" },
        { id: 'documents', icon: ShoppingBag, label: 'Sản Phẩm', badge: null, url: "http://localhost:5173/admin/product" },
    ];
    console.log("user:>>>>>:", user);
    return (

        <div className="flex h-screen bg-gray-50 overflow-hidden">
            {/* Sidebar */}
            <aside
                className={`${isSidebarOpen ? 'w-72' : 'w-20'
                    } bg-gradient-to-b from-indigo-600 via-purple-600 to-pink-500 text-white transition-all duration-300 flex flex-col shadow-2xl relative z-10`}
            >
                {/* Logo */}
                <div className="p-6 flex items-center justify-between border-b border-white/20">
                    {isSidebarOpen ? (
                        <div className="flex items-center space-x-3">
                            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center">
                                <span className="text-2xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                                    A
                                </span>
                            </div>
                            <span className="text-2xl font-bold">AppName</span>
                        </div>
                    ) : (
                        <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center mx-auto">
                            <span className="text-2xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                                A
                            </span>
                        </div>
                    )}
                </div>

                {/* Menu Items */}
                <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
                    {menuItems.map(item => {
                        const Icon = item.icon;
                        return (
                            <NavLink
                                key={item.id}
                                to={item.url}
                                className={({ isActive }) =>
                                    `w-full flex items-center space-x-4 px-4 py-3 rounded-xl transition-all duration-200 group ${isActive
                                        ? "bg-white text-indigo-600 shadow-lg"
                                        : "hover:bg-white/10 text-white/90 hover:text-white"
                                    }`
                                }
                                end={item.exact}
                            >
                                <Icon className="w-6 h-6 flex-shrink-0" />
                                {isSidebarOpen && (
                                    <>
                                        <span className="flex-1 text-left font-medium">{item.label}</span>
                                        {item.badge && (
                                            <span className={`px-2 py-1 rounded-full text-xs font-bold ${"bg-white/20 text-white"}`}>
                                                {item.badge}
                                            </span>
                                        )}
                                    </>
                                )}
                            </NavLink>
                        );
                    })}
                </nav>

                {/* User Profile */}
                <div className="p-4 border-t border-white/20">
                    <div
                        className="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/10 cursor-pointer transition-colors"
                        onClick={() => setIsProfileOpen(!isProfileOpen)}
                    >
                        <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center flex-shrink-0">
                            <User className="w-6 h-6 text-indigo-600" />
                        </div>
                        {isSidebarOpen && (
                            <>
                                <div className="flex-1">
                                    <p className="font-semibold text-sm">{user.name || "Admin User"}</p>
                                    <p className="text-xs text-white/70">{user.email || "example@gmail.com"}</p>
                                </div>
                                <ChevronDown className={`w-5 h-5 transition-transform ${isProfileOpen ? 'rotate-180' : ''}`} />
                            </>
                        )}
                    </div>
                    {isProfileOpen && isSidebarOpen && (
                        <div className="mt-2 space-y-1">
                            <button className="w-full flex items-center space-x-3 px-4 py-2 rounded-xl hover:bg-white/10 text-sm transition-colors">
                                <User className="w-4 h-4" />
                                <span>Hồ sơ</span>
                            </button>
                            <button onClick={handleLogout} className="w-full flex items-center space-x-3 px-4 py-2 rounded-xl hover:bg-white/10 text-sm transition-colors">
                                <LogOut className="w-4 h-4" />
                                <span>Đăng xuất</span>
                            </button>
                        </div>
                    )}
                </div>
            </aside>

            {/* Main Content */}
            <div className="flex-1 flex flex-col overflow-hidden">
                {/* Top Navigation */}
                <header className="bg-white shadow-sm z-10">
                    <div className="flex items-center justify-between px-8 py-4">
                        <div className="flex items-center space-x-4">
                            <button
                                onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                                className="p-2 hover:bg-gray-100 rounded-xl transition-colors"
                            >
                                {isSidebarOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
                            </button>
                            <div className="relative">
                                <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                                <input
                                    type="text"
                                    placeholder="Tìm kiếm..."
                                    className="pl-12 pr-4 py-2 border-2 border-gray-300 rounded-xl w-96 focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none"
                                />
                            </div>
                        </div>
                        <div className="flex items-center space-x-4">
                            <button className="relative p-2 hover:bg-gray-100 rounded-xl transition-colors">
                                <Bell className="w-6 h-6 text-gray-600" />
                                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
                            </button>
                            <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full cursor-pointer hover:shadow-lg transition-shadow"></div>
                        </div>
                    </div>
                </header>
                <main className="flex-1 overflow-y-auto p-8">
                    <Outlet />
                </main>
            </div>
        </div >
    );
}