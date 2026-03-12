import api from "./axiosInstance";

export const registerUser = async (data) => {
    try {
        const res = await api.post("/auth/register", data);
        return res.data;
    } catch (err) {
        throw err.response?.data || { message: "Lỗi không xác định" };
    }
};
