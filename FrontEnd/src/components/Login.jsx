import { useState } from "react";
import { useAuth } from "..//AuthContext/AuthContext";
import { useNavigate } from "react-router-dom";
import { EyeIcon, EyeOffIcon, LockIcon, MailIcon } from "lucide-react";

export default function Login() {
  const { login, loading } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();
  const handleRegister = () => {
    navigate("/register")
  }
  const { user } = useAuth();
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    try {
      const success = await login(email, password);

      if (!success) {
        setError("Login failed");
        return;
      }

      // ⬇️ Lấy user từ AuthContext
      if (user?.id === "AD0000001") {
        navigate("/admin");
      } else {
        navigate("/home");
      }

      console.log("✅ Login success:", user);

    } catch (err) {
      setError(err.response?.data?.message || "Login failed");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100 flex items-center justify-center p-8">
      {/* Background decoration */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-80 -right-80 w-[640px] h-[640px] bg-purple-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob"></div>
        <div className="absolute -bottom-80 -left-80 w-[640px] h-[640px] bg-pink-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-2000"></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[640px] h-[640px] bg-indigo-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-4000"></div>
      </div>

      {/* Login Card */}
      <div className="relative w-full max-w-3xl">
        <div className="bg-white rounded-[32px] shadow-2xl p-16 backdrop-blur-sm bg-opacity-95">
          {/* Header */}
          <div className="text-center mb-16">
            <h2 className="text-6xl font-bold text-gray-800 mb-4">Chào mừng bạn đến với hệ thống</h2>
            <p className="text-2xl text-gray-500">Đăng nhập để tiếp tục</p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mb-12 p-8 bg-red-50 border-l-8 border-red-500 rounded-2xl animate-shake">
              <p className="text-red-700 text-xl font-medium">{error}</p>
            </div>
          )}

          {/* Form */}
          <div className="space-y-12">
            {/* Email Input */}
            <div>
              <label className="block text-xl font-medium text-gray-700 mb-4">
                Email
              </label>
              <div className="relative">
                <MailIcon className="absolute left-6 top-1/2 transform -translate-y-1/2 w-10 h-10 text-gray-400" />
                <input
                  type="email"
                  placeholder="your@email.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="w-full pl-20 pr-8 py-6 text-xl border-2 border-gray-300 rounded-2xl focus:ring-4 focus:ring-indigo-500 focus:border-transparent transition-all duration-200 outline-none hover:border-gray-400"
                />
              </div>
            </div>

            {/* Password Input */}
            <div>
              <label className="block text-xl font-medium text-gray-700 mb-4">
                Mật khẩu
              </label>
              <div className="relative">
                <LockIcon className="absolute left-6 top-1/2 transform -translate-y-1/2 w-10 h-10 text-gray-400" />
                <input
                  type={showPassword ? "text" : "password"}
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="w-full pl-20 pr-24 py-6 text-xl border-2 border-gray-300 rounded-2xl focus:ring-4 focus:ring-indigo-500 focus:border-transparent transition-all duration-200 outline-none hover:border-gray-400"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-6 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  {showPassword ? <EyeOffIcon className="w-10 h-10" /> : <EyeIcon className="w-10 h-10" />}
                </button>
              </div>
            </div>

            {/* Remember & Forgot */}
            <div className="flex items-center justify-between text-xl">
              <label className="flex items-center cursor-pointer group">
                <input type="checkbox" className="w-8 h-8 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500 cursor-pointer" />
                <span className="ml-4 text-gray-600 group-hover:text-gray-800">Ghi nhớ đăng nhập</span>
              </label>
              <a href="#" className="text-indigo-600 hover:text-indigo-700 font-medium transition-colors">
                Quên mật khẩu?
              </a>
            </div>

            {/* Submit Button */}
            <button
              onClick={handleSubmit}
              disabled={loading}
              className="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-6 text-2xl rounded-2xl font-semibold shadow-lg hover:shadow-xl hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-[1.02] active:scale-[0.98]"
            >
              {loading ? (
                <span className="flex items-center justify-center">
                  <svg className="animate-spin -ml-1 mr-6 h-10 w-10 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Đang đăng nhập...
                </span>
              ) : (
                'Đăng nhập'
              )}
            </button>
          </div>

          {/* Sign up link */}
          <p className="mt-16 text-center text-xl text-gray-600">
            Chưa có tài khoản?{' '}
            <button onClick={handleRegister} className="text-indigo-600 hover:text-indigo-700 font-semibold transition-colors">
              Đăng ký ngay
            </button>
          </p>

          {/* Demo info */}
          <div className="mt-12 p-8 bg-blue-50 rounded-2xl border-2 border-blue-200">
            <p className="text-lg text-blue-800 text-center">
              <strong>Demo:</strong> email: demo@example.com | password: password
            </p>
          </div>
        </div>
      </div>

      {/* <style>{`
        @keyframes blob {
          0%, 100% { transform: translate(0, 0) scale(1); }
          25% { transform: translate(20px, -50px) scale(1.1); }
          50% { transform: translate(-20px, 20px) scale(0.9); }
          75% { transform: translate(50px, 50px) scale(1.05); }
        }
        .animate-blob {
          animation: blob 7s infinite;
        }
        .animation-delay-2000 {
          animation-delay: 2s;
        }
        .animation-delay-4000 {
          animation-delay: 4s;
        }
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          25% { transform: translateX(-10px); }
          75% { transform: translateX(10px); }
        }
        .animate-shake {
          animation: shake 0.3s ease-in-out;
        }
      `}</style> */}
    </div>
  );
}