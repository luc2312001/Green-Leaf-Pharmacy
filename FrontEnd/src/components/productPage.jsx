import React, { useEffect, useState } from 'react';
import { ShoppingCart, User, ChevronLeft, ChevronRight, Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { listProducts, searchProducts } from '../api/product.js' 

export default function Product() {
  const navigate = useNavigate();

  // UI state
  const [category, setCategory] = useState(4); // default THUOC
  const [products, setProducts] = useState([]);
  const [pageNum, setPageNum] = useState(1);
  const [pageSize, setPageSize] = useState(12);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Search form state
  const [search, setSearch] = useState({
    key_word: null,
    ten_danh_muc: null,
    gia_toi_thieu: null,
    gia_toi_da: null,
    doi_tuong_su_dung: null,
    chi_dinh: null,
    loai_thuoc: null,
    loai_da: null,
    mui_huong: null,
    nuoc_san_xuat: null,
    ten_thuong_hieu: null,
    xuat_xu_thuong_hieu: null,
    sort_by: null,
  });

  // Categories mapping
  const CATEGORIES = [
    { id: 4, label: 'Thuốc' },
    { id: 5, label: 'Chăm Sóc Cá Nhân' },
    { id: 1, label: 'Thiết Bị Y Tế' },
    { id: 2, label: 'Thực Phẩm Chức Năng' },
    { id: 3, label: 'Dược Mỹ Phẩm' },
  ];

  useEffect(() => {
    loadList();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category, pageNum, pageSize]);

  async function loadList() {
    setLoading(true);
    setError(null);
    try {
      const data = await listProducts({ pageNum, category, limit: pageSize });
      // expecting response shape: { items: [...], totalPages: N }
      setProducts(data.items || []);
      setTotalPages(data.totalPages || 1);
    } catch (err) {
      console.error(err);
      setError(err?.message || 'Failed to load products');
    } finally {
      setLoading(false);
    }
  }

  async function handleSearchSubmit(e) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const query = {
        ...search,
        pagenum: 1,
        pagesize: pageSize,
        // ten_danh_muc: CATEGORIES.find((c) => c.id === category)?.label,
      };
      const data = await searchProducts(query);
      setProducts(data.items || []);
      setTotalPages(data.totalPages || 1);
      setPageNum(1);
    } catch (err) {
      console.error(err);
      setError(err?.message || 'Search failed');
    } finally {
      setLoading(false);
    }
  }

  function gotoDetail(id) {
    navigate(`/product-detail/${id}`);
  }

  return (
    <div className="min-h-screen bg-green-50 text-gray-800">
      {/* NAVBAR */}
      <header className="bg-white shadow sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-6">
              <div className="text-2xl font-bold text-green-700">🌿 PharmLeaf</div>
              <nav className="hidden md:flex gap-4 items-center text-sm">
                <a href="/" className="hover:underline">Home (About US)</a>
                <a href="/departments" className="hover:underline">Departments</a>
                <a href="/product" className="font-semibold text-green-700">Product</a>
                <a href="/dashboard" className="hover:underline">Dashboard</a>
              </nav>
            </div>

            <div className="flex items-center gap-4">
              <button aria-label="shopping-cart" className="p-2 rounded-md hover:bg-green-100">
                <ShoppingCart size={20} />
              </button>
              <button aria-label="user-account" className="p-2 rounded-md hover:bg-green-100">
                <User size={20} />
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* HERO + Search */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid md:grid-cols-4 gap-6">
          {/* Left column - categories */}
          <aside className="bg-white rounded-2xl p-4 shadow">
            <h3 className="font-semibold text-lg mb-4 text-green-800">Categories</h3>
            <div className="flex flex-col gap-2">
              {CATEGORIES.map((c) => (
                <button
                  key={c.id}
                  onClick={() => { setCategory(c.id); setPageNum(1); }}
                  className={`text-left px-3 py-2 rounded-lg transition-colors ${c.id === category ? 'bg-green-100 text-green-800 font-semibold' : 'hover:bg-green-50'}`}>
                  {c.label}
                </button>
              ))}
            </div>

            <div className="mt-6">
              <h4 className="font-medium text-sm mb-2">Quick filters</h4>
              <div className="text-sm text-gray-600">Status, price or brand filters can be added here.</div>
            </div>
          </aside>

          {/* Right column - search + products (span 3 columns) */}
          <section className="md:col-span-3">
            <div className="bg-white rounded-2xl p-4 shadow mb-6">
              <form onSubmit={handleSearchSubmit} className="grid grid-cols-1 md:grid-cols-3 gap-3 items-end">
                <div className="col-span-2">
                  <label className="block text-xs font-medium text-gray-600">Search products</label>
                  <div className="mt-1 relative">
                    <input
                      value={search.key_word}
                      onChange={(e) => setSearch({ ...search, key_word: e.target.value })}
                      placeholder="Search by name, description, brand..."
                      className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-200"
                    />
                    <div className="absolute right-2 top-1/2 -translate-y-1/2">
                      <Search size={18} />
                    </div>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-600">Sort / Page size</label>
                  <div className="mt-1 flex gap-2">
                    <select value={search.sort_by} onChange={(e) => setSearch({ ...search, sort_by: e.target.value })} className="rounded-lg px-2 py-2 border">
                      <option value="">Relevance</option>
                      <option value="price_asc">Price ↑</option>
                      <option value="price_desc">Price ↓</option>
                      <option value="name_asc">Name A-Z</option>
                    </select>
                    <select value={pageSize} onChange={(e) => setPageSize(Number(e.target.value))} className="rounded-lg px-2 py-2 border">
                      <option value={8}>8</option>
                      <option value={12}>12</option>
                      <option value={24}>24</option>
                    </select>
                  </div>
                </div>

                {/* Additional search fields (collapsed on small screens) */}
                <div className="col-span-1 md:col-span-3 grid grid-cols-2 gap-3 mt-2">
                  <input value={search.gia_toi_thieu} onChange={(e) => setSearch({ ...search, gia_toi_thieu: e.target.value })} placeholder="Min price" className="border rounded-lg px-3 py-2" />
                  <input value={search.gia_toi_da} onChange={(e) => setSearch({ ...search, gia_toi_da: e.target.value })} placeholder="Max price" className="border rounded-lg px-3 py-2" />
                  <input value={search.ten_thuong_hieu} onChange={(e) => setSearch({ ...search, ten_thuong_hieu: e.target.value })} placeholder="Brand" className="border rounded-lg px-3 py-2" />
                  <input value={search.nuoc_san_xuat} onChange={(e) => setSearch({ ...search, nuoc_san_xuat: e.target.value })} placeholder="Made in" className="border rounded-lg px-3 py-2" />
                  <input value={search.doi_tuong_su_dung} onChange={(e) => setSearch({ ...search, doi_tuong_su_dung: e.target.value })} placeholder="Intended for" className="border rounded-lg px-3 py-2" />
                  <input value={search.chi_dinh} onChange={(e) => setSearch({ ...search, chi_dinh: e.target.value })} placeholder="Indication" className="border rounded-lg px-3 py-2" />
                </div>

                <div className="col-span-1 md:col-span-3 text-right mt-2">
                  <button type="submit" className="bg-green-600 text-white px-4 py-2 rounded-lg shadow">Search</button>
                </div>
              </form>
            </div>

            <div className="bg-white rounded-2xl p-4 shadow">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-green-800">{CATEGORIES.find((c) => c.id === category)?.label} <span className="text-sm text-gray-500">(Category #{category})</span></h2>
                <div className="text-sm text-gray-600">{loading ? 'Loading...' : `${products.length} items`}</div>
              </div>

              {error && <div className="text-red-600 mb-2">{error}</div>}

              {/* Products grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {products.map((p) => (
                  <article key={p.Ma_so_san_pham} className="border rounded-2xl p-4 bg-white shadow-sm hover:shadow-md transition-shadow">
                    <div className="flex items-start gap-4">
                      <div className="w-20 h-20 rounded-lg bg-green-50 flex-shrink-0 flex items-center justify-center text-green-700 font-medium">IMG</div>
                      <div className="flex-1">
                        <h3 className="font-semibold text-md">{p.Ten_san_pham}</h3>
                        <div className="text-sm text-gray-500">{p.Loai_san_pham} • {p.Don_vi_tinh}</div>
                        <div className="mt-2 text-green-700 font-semibold">{p.Gia_tien?.toLocaleString?.()} VND</div>
                        <div className="mt-3 flex gap-2">
                          <button onClick={() => gotoDetail(p.Ma_so_san_pham)} className="px-3 py-1 rounded-lg border hover:bg-green-50">View detail</button>
                          <button className="px-3 py-1 rounded-lg bg-green-600 text-white">Add to cart</button>
                        </div>
                      </div>
                    </div>
                  </article>
                ))}

                {!loading && products.length === 0 && (
                  <div className="col-span-full text-center text-sm text-gray-500 py-8">No products found for selected filters.</div>
                )}
              </div>

              {/* pagination floating box */}
              <div className="fixed left-1/2 -translate-x-1/2 bottom-8 bg-white border rounded-full shadow-lg px-4 py-2 flex items-center gap-4">
                <button onClick={() => setPageNum((p) => Math.max(1, p - 1))} className="p-2 rounded-full hover:bg-green-50">
                  <ChevronLeft size={18} />
                </button>
                <div className="text-sm">Page {pageNum} / {totalPages}</div>
                <button onClick={() => setPageNum((p) => Math.min(totalPages, p + 1))} className="p-2 rounded-full hover:bg-green-50">
                  <ChevronRight size={18} />
                </button>
              </div>

            </div>
          </section>
        </div>
      </main>
    </div>
  );
}
