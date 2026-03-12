// ProductDetailPage.jsx
import React, { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { getDetail, getQuestions, getAnswers } from '../api/product.js'; // adjust path to your axios instance

const leafSvg = (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" style={{ display: 'block' }}>
    <path d="M12 3c5.5 0 9 3.8 9 9 0 5-4 9-9 9S3 17 3 12C3 6.8 7.5 3 12 3z" fill="#a7e3a1"/>
    <path d="M12 6c3.6 0 6 2.4 6 6 0 3.4-2.6 6-6 6s-6-2.6-6-6c0-3.8 2.6-6 6-6z" fill="#6fcf97"/>
    <path d="M12 8c-1.8 2.2-1.8 5.8 0 8M12 8c1.8 2.2 1.8 5.8 0 8" stroke="#2f855a" strokeWidth="1.2" strokeLinecap="round"/>
  </svg>
);

const cartIcon = (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-label="Shopping-Card">
    <path d="M6 6h15l-1.5 8.5a2 2 0 0 1-2 1.6H9.2a2 2 0 0 1-2-1.6L6 6z" stroke="#1f7a52" strokeWidth="1.5"/>
    <circle cx="9" cy="20" r="1.6" fill="#1f7a52"/>
    <circle cx="18" cy="20" r="1.6" fill="#1f7a52"/>
  </svg>
);

const userIcon = (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-label="User account">
    <circle cx="12" cy="8" r="4" stroke="#1f7a52" strokeWidth="1.5"/>
    <path d="M4 20c0-4.4 3.6-6 8-6s8 1.6 8 6" stroke="#1f7a52" strokeWidth="1.5" strokeLinecap="round"/>
  </svg>
);

export default function ProductDetailPage() {
  const { id } = useParams();
  const [detail, setDetail] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({}); // { [So_thu_tu]: { items: [], loading: false, open: false } }
  const [loadingDetail, setLoadingDetail] = useState(true);
  const [loadingQuestions, setLoadingQuestions] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let mounted = true;

    async function init() {
      try {
        setLoadingDetail(true);
        const d = await getDetail(id);
        if (!mounted) return;
        setDetail(d);
      } catch (e) {
        setError('Unable to load product details.');
      } finally {
        setLoadingDetail(false);
      }

      try {
        setLoadingQuestions(true);
        const q = await getQuestions(id);
        if (!mounted) return;
        setQuestions(Array.isArray(q) ? q : []);
      } catch (e) {
        setError(prev => prev || 'Unable to load questions.');
      } finally {
        setLoadingQuestions(false);
      }
    }

    init();
    return () => { mounted = false; };
  }, [id]);

  const toggleAnswers = async (quesNum) => {
    setAnswers(prev => ({
      ...prev,
      [quesNum]: { ...(prev[quesNum] || {}), open: !(prev[quesNum]?.open) }
    }));

    // If opening and not yet loaded, fetch answers
    if (!answers[quesNum]?.items) {
      try {
        setAnswers(prev => ({
          ...prev,
          [quesNum]: { ...(prev[quesNum] || {}), loading: true }
        }));
        const a = await getAnswers(quesNum, id);
        setAnswers(prev => ({
          ...prev,
          [quesNum]: { items: Array.isArray(a) ? a : [], loading: false, open: true }
        }));
      } catch (e) {
        setAnswers(prev => ({
          ...prev,
          [quesNum]: { ...(prev[quesNum] || {}), loading: false, items: [] }
        }));
      }
    }
  };

  return (
    <div style={styles.page}>
      <Navbar />
      <main style={styles.main}>
        <header style={styles.header}>
          <div style={styles.headerLeft}>
            <div style={styles.leafBadge}>{leafSvg}</div>
            <h1 style={styles.h1}>Product detail</h1>
            <p style={styles.subTitle}>Detail list of our product</p>
          </div>
          <div style={styles.headerRight}>
            <Link to="/shopping-card" aria-label="Shopping-Card" style={styles.iconBtn}>
              {cartIcon}
            </Link>
            <Link to="/account" aria-label="User account" style={styles.iconBtn}>
              {userIcon}
            </Link>
          </div>
        </header>

        <section style={styles.card}>
          <h2 style={styles.h2}>Product detail</h2>
          {loadingDetail && <p style={styles.muted}>Loading product...</p>}
          {!loadingDetail && detail && (
            <div style={styles.detailGrid}>
              {Object.entries(detail).map(([key, value]) => (
                <div key={key} style={styles.detailRow}>
                  <span style={styles.detailKey}>{formatKey(key)}</span>
                  <span style={styles.detailValue}>{String(value)}</span>
                </div>
              ))}
            </div>
          )}
          {!loadingDetail && !detail && <p style={styles.muted}>No product detail found.</p>}
        </section>

        <section style={styles.card}>
          <h2 style={styles.h2}>Questions and answers</h2>
          <p style={styles.muted}>Find your problems here</p>
          {loadingQuestions && <p style={styles.muted}>Loading questions...</p>}
          {!loadingQuestions && questions.length === 0 && (
            <p style={styles.muted}>No questions yet.</p>
          )}
          {!loadingQuestions && questions.length > 0 && (
            <div style={{ display: 'grid', gap: '16px' }}>
              {questions.map((q) => (
                <div key={q.So_thu_tu} style={styles.qaItem}>
                  <div style={styles.qaHeader}>
                    <h3 style={styles.qaTitle}>Question {q.So_thu_tu}</h3>
                    <button
                      onClick={() => toggleAnswers(q.So_thu_tu)}
                      style={styles.answerToggle}
                      aria-expanded={!!answers[q.So_thu_tu]?.open}
                      aria-controls={`answers-${q.So_thu_tu}`}
                      title="See answers"
                    >
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                        <path d="M12 5l7 7-7 7-7-7 7-7z" fill="#1f7a52" />
                      </svg>
                    </button>
                  </div>

                  <div style={styles.metaRow}>
                    <span style={styles.meta}><strong>Product code:</strong> {q.Ma_so_san_pham}</span>
                    <span style={styles.meta}><strong>Likes:</strong> {q.Luot_like}</span>
                    <span style={styles.meta}><strong>Asked at:</strong> {q.Thoi_gian_hoi}</span>
                    <span style={styles.meta}><strong>Asker:</strong> Anonymous</span>
                  </div>

                  <p style={styles.content}>{q.Noi_dung}</p>

                  <div
                    id={`answers-${q.So_thu_tu}`}
                    style={{ display: answers[q.So_thu_tu]?.open ? 'block' : 'none', marginTop: 8 }}
                  >
                    {answers[q.So_thu_tu]?.loading && (
                      <p style={styles.muted}>Loading answers...</p>
                    )}
                    {!answers[q.So_thu_tu]?.loading && (
                      <div style={styles.answerList}>
                        {(answers[q.So_thu_tu]?.items || []).map((a) => (
                          <div key={`${a.So_thu_tu}-${a.So_thu_tu_cau_hoi}`} style={styles.answerItem}>
                            <div style={styles.answerHeader}>
                              <span style={styles.answerBadge}>Answer {a.So_thu_tu}</span>
                              <span style={styles.metaSmall}>
                                <strong>To question:</strong> {a.So_thu_tu_cau_hoi}
                              </span>
                            </div>
                            <div style={styles.metaRow}>
                              <span style={styles.metaSmall}><strong>Product code:</strong> {a.Ma_so_san_pham}</span>
                              <span style={styles.metaSmall}><strong>Likes:</strong> {a.Luot_like}</span>
                              <span style={styles.metaSmall}><strong>Answered at:</strong> {a.Thoi_gian_tra_loi}</span>
                              <span style={styles.metaSmall}><strong>Responder:</strong> Anonymous</span>
                            </div>
                            <p style={styles.content}>{a.Noi_dung}</p>
                          </div>
                        ))}
                        {(answers[q.So_thu_tu]?.items || []).length === 0 && (
                          <p style={styles.muted}>No answers yet.</p>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {error && <div role="alert" style={styles.error}>{error}</div>}
      </main>
      <footer style={styles.footer}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          {leafSvg}
          <span style={styles.muted}>Green Leaf Pharmacy — Caring for your health</span>
        </div>
      </footer>
    </div>
  );
}

function Navbar() {
  return (
    <nav style={styles.nav}>
      <div style={styles.navLeft}>
        <div style={styles.brand}>
          {leafSvg}
          <span style={styles.brandText}>Green Leaf Pharmacy</span>
        </div>
        <div style={styles.links}>
          <Link to="/" style={styles.link}>Home</Link>
          <Link to="/about" style={styles.subLink}>(About US)</Link>
          <Link to="/departments" style={styles.link}>Departments</Link>
          <Link to="/products" style={styles.link}>Product</Link>
          <Link to="/dashboard" style={styles.link}>Dashboard</Link>
        </div>
      </div>
      <div style={styles.navRight}>
        <Link to="/shopping-card" aria-label="Shopping-Card" style={styles.iconBtn}>{cartIcon}</Link>
        <Link to="/account" aria-label="User account" style={styles.iconBtn}>{userIcon}</Link>
      </div>
    </nav>
  );
}

function formatKey(k) {
  return k
    .replace(/_/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase());
}

const styles = {
  page: {
    minHeight: '100vh',
    background: 'linear-gradient(180deg, #f6fbf7 0%, #eaf7ea 100%)',
    color: '#123c2b',
  },
  nav: {
    position: 'sticky',
    top: 0,
    zIndex: 20,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '10px 20px',
    background: 'rgba(255,255,255,0.8)',
    backdropFilter: 'saturate(140%) blur(6px)',
    borderBottom: '1px solid #d5ead6',
  },
  navLeft: { display: 'flex', alignItems: 'center', gap: 16 },
  brand: { display: 'flex', alignItems: 'center', gap: 8 },
  brandText: { fontWeight: 700, color: '#176a45' },
  links: { display: 'flex', alignItems: 'center', gap: 14 },
  link: {
    color: '#176a45',
    textDecoration: 'none',
    fontWeight: 600,
    padding: '6px 10px',
    borderRadius: 8,
    transition: 'background 0.2s',
  },
  subLink: {
    color: '#2f855a',
    textDecoration: 'none',
    fontWeight: 500,
    fontStyle: 'italic',
    opacity: 0.9,
  },
  navRight: { display: 'flex', alignItems: 'center', gap: 10 },
  iconBtn: {
    display: 'grid',
    placeItems: 'center',
    width: 36,
    height: 36,
    borderRadius: 10,
    background: '#e4f4e4',
    border: '1px solid #cfe9cf',
  },
  main: { maxWidth: 980, margin: '0 auto', padding: '24px 16px 80px' },
  header: {
    display: 'flex',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  headerLeft: { display: 'flex', alignItems: 'center', gap: 12 },
  headerRight: { display: 'flex', alignItems: 'center', gap: 8 },
  leafBadge: {
    width: 32,
    height: 32,
    borderRadius: 10,
    background: '#e4f7e4',
    display: 'grid',
    placeItems: 'center',
    border: '1px solid #cfe9cf',
  },
  h1: { fontSize: 24, margin: 0, color: '#176a45' },
  subTitle: { margin: 0, fontSize: 13, color: '#3b6f58' },
  card: {
    background: '#ffffff',
    border: '1px solid #d5ead6',
    borderRadius: 16,
    padding: 16,
    marginTop: 16,
    boxShadow: '0 6px 24px rgba(23,106,69,0.06)',
  },
  h2: { margin: '0 0 12px', fontSize: 18, color: '#176a45' },
  detailGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: 10,
  },
  detailRow: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    background: '#f5fbf6',
    border: '1px solid #e2f3e3',
    padding: '8px 10px',
    borderRadius: 10,
  },
  detailKey: { fontWeight: 600, color: '#2f855a' },
  detailValue: { color: '#245b43' },
  qaItem: {
    border: '1px solid #e2f3e3',
    borderRadius: 12,
    padding: 12,
    background: '#f8fcf8',
  },
  qaHeader: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
  },
  qaTitle: { margin: 0, fontSize: 16, color: '#176a45' },
  answerToggle: {
    display: 'grid',
    placeItems: 'center',
    width: 32,
    height: 32,
    borderRadius: 8,
    background: '#e4f4e4',
    border: '1px solid #cfe9cf',
    cursor: 'pointer',
  },
  metaRow: { display: 'flex', flexWrap: 'wrap', gap: 10, marginTop: 6 },
  meta: { fontSize: 13, color: '#336b53' },
  metaSmall: { fontSize: 12, color: '#3b6f58' },
  content: {
    marginTop: 8,
    background: '#ffffff',
    border: '1px solid #e2f3e3',
    borderRadius: 10,
    padding: 10,
    color: '#23473a',
  },
  answerList: { display: 'grid', gap: 10 },
  answerItem: {
    border: '1px solid #dcefdc',
    borderRadius: 10,
    padding: 10,
    background: '#ffffff',
  },
  answerHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    marginBottom: 4,
  },
  answerBadge: {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: 999,
    background: '#e4f7e4',
    border: '1px solid #cfe9cf',
    fontSize: 12,
    color: '#176a45',
    fontWeight: 700,
  },
  muted: { color: '#5a7c69', fontSize: 13 },
  error: {
    marginTop: 16,
    padding: 12,
    background: '#fff3f3',
    border: '1px solid #ffd5d5',
    color: '#a33a3a',
    borderRadius: 10,
  },
  footer: {
    borderTop: '1px solid #d5ead6',
    padding: '18px 16px',
    background: '#ffffff',
  },
};
