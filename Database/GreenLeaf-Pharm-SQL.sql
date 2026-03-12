 -- Type --

PRINT '>>> TYPE SYSTEM';

CREATE TYPE MA_TYPE FROM CHAR(9);  /* Mã -> dùng MA_TYPE */ 
CREATE TYPE MA_SO_THUE_TYPE FROM CHAR(10); /* Mã số thuế: 10 số  */ 
CREATE TYPE SO_DINH_DANH_TYPE FROM CHAR(12); /* Số định danh */
CREATE TYPE SO_DIEN_THOAI_TYPE FROM CHAR(10); /* Số điện thoại 10 số */
CREATE TYPE DIA_CHI_TYPE FROM NVARCHAR(30); /* Địa chỉ */
CREATE TYPE TIEN_TYPE FROM DECIMAL(10,2); /* Tiền */
CREATE TYPE SO_DANG_KY_TYPE FROM VARCHAR(14); /* So dang ky san pham */

PRINT '>>> END TYPE SYSTEM';

GO

PRINT '>>> BEGIN CREATE TABLE';

-- 1st Priority --

CREATE TABLE CONG_TY_SAN_XUAT (
    Quoc_gia       NVARCHAR(50),
    Giay_phep_kinh_doanh                NVARCHAR(100),
    Ten_cong_ty    NVARCHAR(100),
    Dia_chi        DIA_CHI_TYPE         NOT NULL,
    Ma_so_thue     MA_SO_THUE_TYPE      NOT NULL,


    CONSTRAINT PK_CONG_TY_SAN_XUAT PRIMARY KEY (Ma_so_thue)
);


CREATE TABLE THUONG_HIEU (
    Ma_so       MA_TYPE         PRIMARY KEY,
    Ten_thuong_hieu     NVARCHAR(50),
    Xuat_xu             NVARCHAR(30)
);

CREATE TABLE DANH_MUC
(
    Ten                     NVARCHAR(30)     PRIMARY KEY,
    So_luong_san_pham       INT             CHECK(so_luong_san_pham > 0),
    Ten_danh_muc_cha        NVARCHAR(30)
    /*
    CONSTRAINT TDMC_T_FKEY
        FOREIGN KEY (Ten_danh_muc_cha) REFERENCES DANH_MUC(Ten)
            ON DELETE NO ACTION
            ON UPDATE CASCADE
    */
);

CREATE TABLE QUANG_CAO
(
    Ma_quang_cao    MA_TYPE         PRIMARY KEY,
    File_qc            VARCHAR(30)     UNIQUE,
    Nen_tang        VARCHAR(9),
    Muc_hieu_qua    INT             DEFAULT 0,
    Thoi_gian_dang_ky               DATETIME,
    Thoi_gian_het_han               DATETIME,
    Chi_phi         TIEN_TYPE       CHECK(Chi_phi >= 0)

);

CREATE TABLE NGUOI_DUNG (
    Ma_so               MA_TYPE          PRIMARY KEY,
    Ho_va_ten           NVARCHAR(50),
    So_dien_thoai       SO_DIEN_THOAI_TYPE,
    Gioi_tinh          	CHAR,
    Ngay_sinh           DATE,
    Hash_key_password   VARCHAR(200),


    CONSTRAINT CK_Ngay_sinh 
        CHECK (Ngay_sinh <= DATEADD(YEAR, -16, GETDATE()))
);

/* DON VI GIAO HANG */
CREATE TABLE DON_VI_GIAO_HANG
(
	-- Attributes --
	Ma_don_vi_giao_hang		MA_TYPE NOT NULL,
	So_luong_don_da_giao	INT		NOT NULL DEFAULT 0,


	-- Constraints --
	CONSTRAINT DVGH_PK PRIMARY KEY (Ma_don_vi_giao_hang),


	CONSTRAINT VALID_SLDDG_CHK CHECK (So_luong_don_da_giao >= 0)
);

-- 2nd Priority --

CREATE TABLE HOP_DONG(
    Thoi_han_hop_dong	   INT,
    Van_ban_hop_dong	   NVARCHAR(100),
    Ma_so_thue_cong_ty     MA_SO_THUE_TYPE,


    CONSTRAINT PK_HOP_DONG PRIMARY KEY (Thoi_han_hop_dong, Van_ban_hop_dong, Ma_so_thue_cong_ty),


    CONSTRAINT FK_HP_CTSS FOREIGN KEY (Ma_so_thue_cong_ty)
        REFERENCES CONG_TY_SAN_XUAT(Ma_so_thue)
            ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE NGUOI_MUA_HANG (
    Ma_so_nguoi_mua_hang    MA_TYPE           NOT NULL,
    Dia_chi_mac_dinh        DIA_CHI_TYPE      NOT NULL,


    CONSTRAINT PK_NGUOI_MUA_HANG PRIMARY KEY (Ma_so_nguoi_mua_hang),


    CONSTRAINT FK_NMH_NGUOIDUNG FOREIGN KEY (Ma_so_nguoi_mua_hang)
        REFERENCES NGUOI_DUNG (Ma_so)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE DIA_CHI (
    Ma_so_nguoi_dung    MA_TYPE          NOT NULL,
    Dia_chi             DIA_CHI_TYPE     NOT NULL,


    CONSTRAINT PK_DIA_CHI PRIMARY KEY (Ma_so_nguoi_dung, Dia_chi),


    CONSTRAINT FK_DC_ND FOREIGN KEY (Ma_so_nguoi_dung)
        REFERENCES NGUOI_DUNG(Ma_so)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE NHAN_VIEN (
    Ma_so_nhan_vien         MA_TYPE             PRIMARY KEY,
    So_dinh_danh            SO_DINH_DANH_TYPE   UNIQUE,    
    Ngay_bat_dau_lam_viec   DATE                DEFAULT GETDATE(),
    Luong                   TIEN_TYPE           CHECK(Luong >= 0),
    Anh_nhan_vien           NVARCHAR(100),
    Email                   NVARCHAR(100),
    Thuong_them             TIEN_TYPE           CHECK(Thuong_them >= 0),
    Nganh_nghe              VARCHAR(50),
    Ngay_lam_viec           INT                 CHECK(Ngay_lam_viec >= 1 AND Ngay_lam_viec <= 7),


    CONSTRAINT FK_NV_ND FOREIGN KEY (Ma_so_nhan_vien)
        REFERENCES NGUOI_DUNG(Ma_so)
            ON UPDATE CASCADE
            ON DELETE CASCADE,


     CONSTRAINT CK_NV_NN CHECK (
        Nganh_nghe IN (
            'DUOC_SI', 
            'NHAN_VIEN_CHUYEN_MON',
            'NHAN_VIEN_MARKETING',
            'NHAN_VIEN_GIAO_HANG'
        )
    )
);

-- 3rd Priority --


CREATE TABLE CHI_NHANH
(
    Ma_chi_nhanh    MA_TYPE     PRIMARY KEY,
    Trang_thai      CHAR        DEFAULT 'C', -- C:close, O:Open --
    Dien_thoai      SO_DIEN_THOAI_TYPE,
    Dia_chi         DIA_CHI_TYPE,
    Ten_chi_nhanh   VARCHAR(30),
    Thoi_gian_mo_cua    TIME,
    Thoi_gian_dong_cua  TIME,
    Ngay_lam_viec   INT     Check(Ngay_lam_viec > 0 AND Ngay_lam_viec <= 6),
    -- Lam viec tu t2-t7 max, cn nghi --
    Ma_so_duoc_si_quan_ly   MA_TYPE,
    /*
    - Circular reference key --
    CONSTRAINT MSDSQL_FKEY
        FOREIGN KEY (Ma_so_duoc_si_quan_ly) REFERENCES DUOC_SI(Ma_so_nhan_vien)
            ON DELETE SET DEFAULT
            ON UPDATE CASCADE,
    */
    CONSTRAINT TIME_WORK
        CHECK (thoi_gian_dong_cua > thoi_gian_mo_cua),
    CONSTRAINT OPEN_TIME_CHK
	  CHECK (Thoi_gian_mo_cua >= '07:00:00'),
    CONSTRAINT CLOSE_TIME_CHK
	  CHECK (Thoi_gian_dong_cua <= '23:00:00')
);

CREATE TABLE PHIEU_GIAM_GIA
(   
    Ma_phieu            MA_TYPE     PRIMARY KEY,
    Loai_ma_giam_gia    CHAR,	/*T: TrucTiep, V: Voucher*/
    Thoi_gian_bat_dau_hieu_luc      DATETIME,
    Thoi_gian_het_hieu_luc          DATETIME,
    So_luong_ma         INT         CHECK(So_luong_ma >= 0),
    Gia_don_hang_toi_thieu          TIEN_TYPE       
        CHECK(Gia_don_hang_toi_thieu >= 0),
    Loai_giam_phan_tram_tien        CHAR        NOT NULL, 
/* P: %, T: Tien */
    Do_uu_tien          INT         CHECK(Do_uu_tien >= 0),
    Cho_don_cho_san_pham            CHAR        NOT NULL,
    Ma_so_nguoi_so_huu              MA_TYPE,
    CONSTRAINT MSNSH_FKEY
        FOREIGN KEY (Ma_so_nguoi_so_huu)
            REFERENCES NGUOI_MUA_HANG(Ma_so_nguoi_mua_hang)
            ON DELETE SET NULL
            ON UPDATE CASCADE,
);

/* NHAN VIEN GIAO HANG */
CREATE TABLE NHAN_VIEN_GIAO_HANG
(
	-- Attributes --
	Ma_so_nhan_vien		MA_TYPE		NOT NULL DEFAULT '000000000',
	Bang_lai_xe			CHAR(12)	NOT NULL,
	Ca_giao_hang		CHAR(1), -- {'S': 'Sang', 'C': 'Chieu'; 'T': Toi}
	Ma_don_vi_giao_hang	MA_TYPE,


	-- Constraints --
	CONSTRAINT NVGH_PK PRIMARY KEY (Ma_so_nhan_vien),
	CONSTRAINT NVGH_SK UNIQUE (Bang_lai_xe),


	CONSTRAINT VALID_CA_CHK CHECK (Ca_giao_hang IN ('S', 'C', 'T')),


	CONSTRAINT NVGH2NV_FK FOREIGN KEY (Ma_so_nhan_vien) REFERENCES NHAN_VIEN(Ma_so_nhan_vien)
						  ON DELETE SET DEFAULT ON UPDATE CASCADE,
	CONSTRAINT NVGH2DVGH_PK FOREIGN KEY (Ma_don_vi_giao_hang) REFERENCES DON_VI_GIAO_HANG(Ma_don_vi_giao_hang)
							ON DELETE SET NULL ON UPDATE CASCADE
);


/* CONG TY GIAO HANG */
CREATE TABLE CONG_TY_GIAO_HANG
(
	-- Attributes --
	Ma_so_thue			MA_SO_THUE_TYPE	NOT NULL,
	Ten					NVARCHAR(30)	NOT NULL,
	Hop_dong			MA_TYPE			NOT NULL, -- Current contract has expired? => Sign new one, possibly!
	Ma_don_vi_giao_hang	MA_TYPE,


	-- Constraints --
	CONSTRAINT CTGH_PK PRIMARY KEY (Ma_so_thue),
	CONSTRAINT CTGH_SK UNIQUE (Hop_dong),


	CONSTRAINT CTGH2DVGH_PK FOREIGN KEY (Ma_don_vi_giao_hang) REFERENCES DON_VI_GIAO_HANG(Ma_don_vi_giao_hang)
							ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE DUOC_SI (
    Ma_so_nhan_vien          MA_TYPE       PRIMARY KEY,
    Ma_so_chi_nhanh_lam_viec MA_TYPE,


    CONSTRAINT FK_DUOC_SI FOREIGN KEY (Ma_so_nhan_vien)
        REFERENCES NHAN_VIEN(Ma_so_nhan_vien)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    /*
    -- Circular Referencing
    CONSTRAINT FK_DS_CN FOREIGN KEY (Ma_so_chi_nhanh_lam_viec)
        REFERENCES CHI_NHANH(Ma_chi_nhanh)
        ON UPDATE CASCADE ON DELETE SET NULL
    */
);


/* NHAN VIEN MARKETING */
CREATE TABLE NHAN_VIEN_MARKETING
(
	-- Attributes --
	Ma_so_nhan_vien		MA_TYPE			NOT NULL DEFAULT '000000000',
	Kinh_nghiem			NVARCHAR(MAX)	DEFAULT N'',
	So_luot_tham_gia	INT				NOT NULL DEFAULT 0,


	-- Constraints --
	CONSTRAINT NVM_PK PRIMARY KEY (Ma_so_nhan_vien),


    CONSTRAINT JOIN_TIMES CHECK (So_luot_tham_gia >= 0),


	CONSTRAINT NVM2NV_FK FOREIGN KEY (Ma_so_nhan_vien) REFERENCES NHAN_VIEN(Ma_so_nhan_vien)
						 ON DELETE SET DEFAULT ON UPDATE CASCADE
);


/* NHAN VIEN CHUYEN MON */
CREATE TABLE NHAN_VIEN_CHUYEN_MON
(
	-- Attributes --
	Ma_so_nhan_vien MA_TYPE			NOT NULL DEFAULT '000000000',
	Bang_cap		NVARCHAR(255)	NOT NULL,
	Mo_ta			NVARCHAR(MAX)	DEFAULT N'',
	Chuyen_khoa		NVARCHAR(255)	NOT NULL,
	Kinh_nghiem		NVARCHAR(MAX)	DEFAULT N'',
	Chuc_danh		NVARCHAR(100)	NOT NULL,


	-- Constraints --
	CONSTRAINT NVCM_PK PRIMARY KEY (Ma_so_nhan_vien),


	CONSTRAINT NVCM2NV_FK FOREIGN KEY (Ma_so_nhan_vien) REFERENCES NHAN_VIEN(Ma_so_nhan_vien)
						  ON DELETE SET DEFAULT ON UPDATE CASCADE
);

CREATE TABLE SAN_PHAM (


    /* Loai san pham:
     *      1: Thiet_bi_y_te
     *      2: Thuc_pham_chuc_nang
     *      3: Duoc_my_pham
     *      4: Thuoc
     *      5: Cham soc ca nhan
     */


    Ma_so_san_pham    MA_TYPE        NOT NULL,
    Ten_san_pham      NVARCHAR(50)   UNIQUE     NOT NULL,
    Luu_y             NVARCHAR(100),
    Gia_tien          TIEN_TYPE      CHECK(Gia_tien >= 0),
    Loai_san_pham     INT,
    Don_vi_tinh       NVARCHAR(10),
    Quy_cach          NVARCHAR(50),
    Mo_ta_ngan        NVARCHAR(200),
    Xuat_xu           NVARCHAR(50),
    Ma_so_thue_cong_ty               MA_SO_THUE_TYPE,
    Tac_dung_phu      NVARCHAR(200),
    Ma_so_thuong_hieu MA_TYPE,
    Ten_danh_muc      NVARCHAR(30),
    Cong_dung         NVARCHAR(200),
    Cach_dung         NVARCHAR(200),
    Bao_quan          NVARCHAR(200),
    Ma_so_nhan_vien_kiem_duyet       MA_TYPE,
    /*Trang thai: O -> OnShelf, S-> Shutdown */
    Trang_thai        CHAR          DEFAULT 'O',

    CONSTRAINT PK_SAN_PHAM PRIMARY KEY (Ma_so_san_pham),


    CONSTRAINT FK_SP_CTSS FOREIGN KEY (Ma_so_thue_cong_ty)
        REFERENCES CONG_TY_SAN_XUAT(Ma_so_thue)
        ON UPDATE CASCADE
        ON DELETE SET NULL,


    CONSTRAINT FK_SP_TH FOREIGN KEY (Ma_so_thuong_hieu)
        REFERENCES THUONG_HIEU(Ma_so)
        ON UPDATE CASCADE
        ON DELETE SET NULL,


    CONSTRAINT FK_SP_DM FOREIGN KEY (Ten_danh_muc)
        REFERENCES DANH_MUC(Ten)
        ON UPDATE CASCADE
        ON DELETE SET NULL,


    CONSTRAINT FK_SP_NVCM FOREIGN KEY (Ma_so_nhan_vien_kiem_duyet)
        REFERENCES NHAN_VIEN_CHUYEN_MON(Ma_so_nhan_vien)
        ON UPDATE CASCADE
        ON DELETE SET NULL,


    CONSTRAINT SP_ENUM_LSP CHECK (Loai_san_pham IN (1,2,3,4,5)),
    
    CONSTRAINT SP_ENUM_TRTH CHECK (Trang_thai IN ('O', 'S'))
);

-- 4nd Priority --

/* YEU CAU TU VAN */
/* 0 => Chờ tư van
 * 1 => Đã tư vấn
 * 2 => Chưa thể liên lạc
 * 3 => Đã hủy
 * */
CREATE TABLE YEU_CAU_TU_VAN (
    Ma_tu_van                   MA_TYPE,
    Noi_dung_hoi                NVARCHAR(MAX),
    So_dien_thoai               SO_DIEN_THOAI_TYPE,
    Trang_thai                  INT                 DEFAULT 0,
    Ho_ten_nguoi_duoc_tu_van    NVARCHAR(30),
    Ma_nhan_vien_kiem_duyet     MA_TYPE,
    Ma_nguoi_mua_hang           MA_TYPE,


    CONSTRAINT EmptyCont_CHK CHECK (Noi_dung_hoi <> N''),
    CONSTRAINT Status_CHK CHECK (Trang_thai IN (0, 1, 2, 3)),
    CONSTRAINT AdvisedUser_CHK CHECK (Ho_ten_nguoi_duoc_tu_van <> N''),


    CONSTRAINT YCTV_PK PRIMARY KEY (Ma_tu_van),
    CONSTRAINT YCTV2NMH_FK FOREIGN KEY(Ma_nguoi_mua_hang) REFERENCES NGUOI_MUA_HANG(Ma_so_nguoi_mua_hang)
        ON DELETE SET NULL ON UPDATE CASCADE
);

/* CAU HOI */
CREATE TABLE CAU_HOI (
    So_thu_tu        INT,
    Ma_so_san_pham   MA_TYPE,
    Noi_dung         NVARCHAR(200),
    Luot_like        INT           DEFAULT 0,
    Thoi_gian_hoi    DATETIME      DEFAULT GETDATE(),
    Ma_nguoi_dung_tra_loi   MA_TYPE,


    CONSTRAINT CH_ORDER_CHK CHECK (So_thu_tu >= 0),
    CONSTRAINT CH_CONT_CHK CHECK (Noi_dung <> N''),
    CONSTRAINT CH_LIKE_CHK CHECK (Luot_like >= 0),

    CONSTRAINT CAU_HOI_PK PRIMARY KEY (So_thu_tu, Ma_so_san_pham),
    
    CONSTRAINT CAU_HOI2SP_FK FOREIGN KEY (Ma_so_san_pham) 
      REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
    
    /*
    CONSTRAINT CAU_HOI2ND_FK FOREIGN KEY (Ma_nguoi_dung_tra_loi) 
      REFERENCES NGUOI_DUNG(Ma_so)
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    */
);

/* THUOC */
CREATE TABLE THUOC (
    Ma_so_san_pham          MA_TYPE         NOT NULL,
    Loai_thuoc              INT             NOT NULL DEFAULT 0, -- 0 => Ke don; 1 => Khong ke don
    Mui_vi_Mui_huong        NVARCHAR(100)   DEFAULT N'',
    Chi_dinh                NVARCHAR(100)   DEFAULT N'',
    Thanh_phan              NVARCHAR(100)   DEFAULT N'',
    Giay_cong_bo_san_pham   NVARCHAR(100)   DEFAULT N'',
    Doi_tuong_su_dung       NVARCHAR(100)   DEFAULT N'',
    Dang_bao_che            NVARCHAR(100)   DEFAULT N'',
    So_dang_ki              SO_DANG_KY_TYPE,


    CONSTRAINT TYPE_CHK CHECK (Loai_thuoc IN (0, 1)),


    CONSTRAINT THUOC_PK PRIMARY KEY (Ma_so_san_pham),
    CONSTRAINT THUOC2SP_FK FOREIGN KEY (Ma_so_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON DELETE CASCADE ON UPDATE CASCADE
);


/* CHAM SOC CA NHAN */
CREATE TABLE CHAM_SOC_CA_NHAN (
    Ma_so_san_pham      MA_TYPE         NOT NULL,
    Loai_da             NVARCHAR(100)   DEFAULT N'',
    Mui_vi_Mui_huong    NVARCHAR(100)   DEFAULT N'',
    Chi_dinh            NVARCHAR(100)   DEFAULT N'',
    Doi_tuong_su_dung   NVARCHAR(100)   DEFAULT N'',


    CONSTRAINT CHAM_SOC_CA_NHAN_PK PRIMARY KEY (Ma_so_san_pham),
    CONSTRAINT FK_CS_CN_SP FOREIGN KEY (Ma_so_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
);

CREATE TABLE ANH_SAN_PHAM (
    Ma_so_san_pham   MA_TYPE        NOT NULL,
    Anh_san_pham     NVARCHAR(50)  NOT NULL,


    CONSTRAINT PK_ANH_SAN_PHAM PRIMARY KEY (Ma_so_san_pham, Anh_san_pham),


    CONSTRAINT FK_ASP_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE THIET_BI_Y_TE (
    Ma_so_san_pham   MA_TYPE        NOT NULL,


    CONSTRAINT PK_THIET_BI_Y_TE PRIMARY KEY (Ma_so_san_pham),


    CONSTRAINT FK_TBYT_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE THUC_PHAM_CHUC_NANG (
    Ma_so_san_pham   MA_TYPE        NOT NULL,
    Chi_dinh         NVARCHAR(100),
    Thanh_phan       NVARCHAR(100),
    Giay_cong_bo_san_pham           NVARCHAR(100),
    Mui_vi_huong_vi  NVARCHAR(50),
    Dang_bao_che     NVARCHAR(50),
    Doi_tuong_su_dung               NVARCHAR(50),
    So_dang_ki       VARCHAR(50),


    CONSTRAINT PK_TPCN PRIMARY KEY (Ma_so_san_pham),


    CONSTRAINT FK_TPCN_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE DUOC_MY_PHAM (
    Ma_so_san_pham   MA_TYPE        NOT NULL,
    Loai_da          NVARCHAR(100),
    Chi_dinh         NVARCHAR(100),
    Thanh_phan       NVARCHAR(100),
    Giay_cong_bo_san_pham           NVARCHAR(100),
    Doi_tuong_su_dung               NVARCHAR(50),
    So_dang_ki       INT            CHECK(So_dang_ki >= 0),


    CONSTRAINT PK_DUOC_MY_PHAM PRIMARY KEY (Ma_so_san_pham),


    CONSTRAINT FK_DMP_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE CO_SAN_PHAM (
    Ma_so_san_pham      MA_TYPE        NOT NULL,
    Ma_chi_nhanh        MA_TYPE        NOT NULL,
    So_luong            INT            NOT NULL     DEFAULT 0   CHECK(So_luong >= 0)  ,


    CONSTRAINT PK_CSP PRIMARY KEY (Ma_chi_nhanh, Ma_so_san_pham),


    CONSTRAINT FK_CSP_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT FK_CSP_CN FOREIGN KEY(Ma_chi_nhanh)
        REFERENCES CHI_NHANH(Ma_chi_nhanh)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE ANH_CHI_NHANH
(
    Ma_chi_nhanh    MA_TYPE         DEFAULT '000000000',
    Anh_chi_nhanh   VARCHAR(30)     UNIQUE,    
    PRIMARY KEY(Ma_chi_nhanh, Anh_chi_nhanh),
    CONSTRAINT MCH_FKEY
        FOREIGN KEY (Ma_chi_nhanh) REFERENCES CHI_NHANH(Ma_chi_nhanh)
            ON DELETE SET DEFAULT
            ON UPDATE CASCADE


);


CREATE TABLE GOM_QC_SP (
    Ma_san_pham        MA_TYPE       NOT NULL,
    Ma_quang_cao       MA_TYPE       NOT NULL,


    CONSTRAINT PK_GQS PRIMARY KEY (Ma_san_pham, Ma_quang_cao),


    CONSTRAINT FK_GQS_QC FOREIGN KEY (Ma_quang_cao)
        REFERENCES QUANG_CAO(Ma_quang_cao)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT FK_GQS_SP FOREIGN KEY (Ma_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE AP_DUNG (
    Ma_so_san_pham  MA_TYPE     NOT NULL,
    Ma_phieu        MA_TYPE     NOT NULL,


    CONSTRAINT PK_AP_DUNG PRIMARY KEY (Ma_phieu, Ma_so_san_pham),

    /*
    CONSTRAINT FK_AP_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT FK_AP_PGG FOREIGN KEY (Ma_phieu)
        REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    */
);


/* TRANG THAI DON HANG */
/* TTDH
 * 0 => Chua dat
 * 1 => Dang xu ly
 * 2 => Dang giao
 * 3 => Da giao
 * 4 => Da huy
 * 5 => Tra hang
 */


/* PHUONG THUC THANH TOAN */
/* PTTT
 * 0 => Thanh toan tien mat khi nhan hang
 * 1 => Thanh toan bang chuyen khoan
 * 2 => Thanh toan bang vi MoMo
 * 3 => Thanh toan bang vi ZaloPay
 * 4 => Thanh toan bang the quoc te (Visa, Master, ...), Apple Pay
 * 5 => Thanh toan bang the ATM noi dia va tai khoan ngan hang
 * 6 => Thanh toan bang cong VNPay
 */


/* DON HANG */
CREATE TABLE DON_HANG
(
	-- Attributes --
	Ma_don_hang					    MA_TYPE				NOT NULL,
	Ma_so_nguoi_mua_hang		MA_TYPE				NOT NULL DEFAULT '00000000',
	Ma_don_vi_giao_hang			MA_TYPE,
	Trang_thai_don_hang			 INT					NOT NULL DEFAULT 0, -- TTDH
	Phuong_thuc_thanh_toan		INT					NOT NULL DEFAULT 0, -- PTTT
	Thoi_gian_dat_hang			DATETIME			NOT NULL DEFAULT GETDATE(),
	Thoi_gian_ban_giao		    DATETIME,
	Thoi_gian_ban_giao_du_kien	DATETIME			DEFAULT DATEADD(day, 7, GETDATE()),
	Ho_ten_nguoi_nhan			NVARCHAR(30)		NOT NULL,
	So_dien_thoai_nguoi_nhan	SO_DIEN_THOAI_TYPE	NOT NULL,
	Dia_chi_nhan				DIA_CHI_TYPE		NOT NULL, 
	Phi_van_chuyen				TIEN_TYPE			DEFAULT 0,
	Ma_chi_nhanh_quan_ly		MA_TYPE,


	-- Constraints --
	-- primary key
	CONSTRAINT DON_HANG_PK PRIMARY KEY (Ma_don_hang),


	-- freight
	CONSTRAINT FREIGHT_RATE_CHK CHECK (Phi_van_chuyen >= 0),


	-- enums
	CONSTRAINT VALID_TTDH_CHK CHECK (Trang_thai_don_hang IN (0, 1, 2, 3, 4, 5)),
	CONSTRAINT VALID_PTTT_CHK CHECK (Phuong_thuc_thanh_toan IN (0, 1, 2, 3, 4, 5, 6)),

	-- time
	-- Thoi_gian_ban_giao > Thoi_gian_dat_hang
	-- Thoi_gian_ban_giao_du_kien > Thoi_gian_dat_hang


	-- foreign key constraint 
	CONSTRAINT DH2CN_FK FOREIGN KEY (Ma_chi_nhanh_quan_ly) REFERENCES CHI_NHANH(Ma_chi_nhanh)
						ON DELETE SET NULL ON UPDATE CASCADE,


	CONSTRAINT DH2NMH_FK FOREIGN KEY (Ma_so_nguoi_mua_hang) REFERENCES NGUOI_MUA_HANG(Ma_so_nguoi_mua_hang)
					ON DELETE SET DEFAULT ON UPDATE CASCADE,


	CONSTRAINT DH2DVGH_FK FOREIGN KEY (Ma_don_vi_giao_hang) REFERENCES DON_VI_GIAO_HANG(Ma_don_vi_giao_hang)
					ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE GIAM_GIA_PHAN_TRAM
(
    Ma_phieu            MA_TYPE     PRIMARY KEY,
    Phan_tram_giam      DECIMAL(5,2)    
        CHECK(Phan_tram_giam >= 0 AND Phan_tram_giam <= 1),
    So_tien_giam_toi_da TIEN_TYPE   CHECK(So_tien_giam_toi_da >= 0),
    CONSTRAINT GGPT_MP_FKEY
        FOREIGN KEY (Ma_phieu) REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
);

/* PHIEU GIAM GIA TIEN */
CREATE TABLE GIAM_GIA_TIEN
(
	-- Attributes --
    Ma_phieu        MA_TYPE		NOT NULL,
	So_tien_giam	TIEN_TYPE	NOT NULL,


	-- Constraints --
	CONSTRAINT GGT_PK PRIMARY KEY (Ma_phieu),


	CONSTRAINT VALID_STG_CHK CHECK (So_tien_giam >= 0),


    CONSTRAINT GGT2PGG_FK FOREIGN KEY (Ma_phieu) REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
					 ON DELETE CASCADE ON UPDATE CASCADE
);

/* THAM GIA */
CREATE TABLE THAM_GIA
(
	-- Attributes --
	Ma_so_nhan_vien		MA_TYPE,
	Ma_quang_cao		MA_TYPE,


	-- Constraints --
	CONSTRAINT TG_PK PRIMARY KEY (Ma_so_nhan_vien, Ma_quang_cao),


	CONSTRAINT MNV2NV_FK FOREIGN KEY (Ma_so_nhan_vien) REFERENCES NHAN_VIEN(Ma_so_nhan_vien)
						 ON DELETE CASCADE 
						 ON UPDATE CASCADE,
	CONSTRAINT MQC2NV_FK FOREIGN KEY (Ma_quang_cao) REFERENCES QUANG_CAO(Ma_quang_cao)
						 ON DELETE CASCADE 
						 ON UPDATE CASCADE
);

/* ANH TU VAN */
CREATE TABLE ANH_TU_VAN (
    Ma_tu_van   MA_TYPE       NOT NULL,
    Anh_tu_van  VARCHAR(50)  NOT NULL,   -- actual image path or blob


    CONSTRAINT ATV_PK PRIMARY KEY (Ma_tu_van, Anh_tu_van),


    -- A consulting request must exist before having an image
    CONSTRAINT ATV2TV_FK FOREIGN KEY (Ma_tu_van) REFERENCES YEU_CAU_TU_VAN(Ma_tu_van)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/* GOM TV-SP */
CREATE TABLE GOM_TV_SP (
    Ma_tu_van       MA_TYPE,
    Ma_san_pham     MA_TYPE,

    CONSTRAINT PK_GOM_TV_SP PRIMARY KEY (Ma_tu_van, Ma_san_pham)
    /*
    CONSTRAINT GOM_TV_SP2TV FOREIGN KEY (Ma_tu_van) REFERENCES YEU_CAU_TU_VAN(Ma_tu_van)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT GOM_TV_SP2SP FOREIGN KEY (Ma_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
    */
);

/* CAU TRA LOI */
CREATE TABLE CAU_TRA_LOI (
    So_thu_tu           INT             NOT NULL,
    So_thu_tu_cau_hoi   INT             NOT NULL,
    Ma_so_san_pham      MA_TYPE         NOT NULL,
    Noi_dung            NVARCHAR(MAX)   NOT NULL,
    Luot_like           INT             DEFAULT 0,
    Thoi_gian_tra_loi   DATETIME        NOT NULL DEFAULT GETDATE(),
    Ma_nguoi_mua_dat_cau_hoi MA_TYPE    NOT NULL,


    CONSTRAINT CTL_ORDER_CHK CHECK (So_thu_tu >= 0 AND So_thu_tu_cau_hoi >= 0),
    CONSTRAINT CTL_CONT_CHK CHECK (Noi_dung <> N''),
    CONSTRAINT CTL_LIKE_CHK CHECK (Luot_like >= 0),

    CONSTRAINT CAU_TRA_LOI_PK PRIMARY KEY (So_thu_tu, So_thu_tu_cau_hoi, Ma_so_san_pham)
    
    
    /*
    CONSTRAINT CTL2CAUHOI_FK FOREIGN KEY (So_thu_tu_cau_hoi, Ma_so_san_pham)
        REFERENCES CAU_HOI(So_thu_tu, Ma_so_san_pham)
            ON DELETE CASCADE 
            ON UPDATE CASCADE,
            
    CONSTRAINT CTL2NGUOIDUNG_FK FOREIGN KEY (Ma_nguoi_mua_dat_cau_hoi)
        REFERENCES NGUOI_DUNG(Ma_so)
            ON DELETE CASCADE 
            ON UPDATE CASCADE
    */
);


/* DANH GIA */
CREATE TABLE DANH_GIA (
    So_thu_tu               INT             NOT NULL,
    Ma_so_san_pham          MA_TYPE         NOT NULL,
    Noi_dung                NVARCHAR(MAX)   DEFAULT N'',
    Thoi_gian_danh_gia      DATETIME        NOT NULL DEFAULT GETDATE(),
    So_sao                  INT             DEFAULT 5,
    Ma_so_nguoi_mua_hang    MA_TYPE,
    Ma_don_dat_hang         MA_TYPE,


    CONSTRAINT ORDER_CHK CHECK (So_thu_tu >= 0),
    CONSTRAINT STAR_QUANTITY_CHK CHECK (So_sao >= 0),


    CONSTRAINT DANH_GIA_PK PRIMARY KEY (So_thu_tu, Ma_so_san_pham)
    
    /*
    CONSTRAINT DANH_GIA2SP_FK FOREIGN KEY (Ma_so_san_pham) 
      REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
        
    CONSTRAINT DANH_GIA2NMH_FK FOREIGN KEY (Ma_so_nguoi_mua_hang) 
      REFERENCES NGUOI_MUA_HANG(Ma_so_nguoi_mua_hang)
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
        
    CONSTRAINT DANH_GIA2DON_HANG_FK FOREIGN KEY (Ma_don_dat_hang) 
      REFERENCES DON_HANG(Ma_don_hang)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
    */
);

CREATE TABLE GOM_SP_DH
( 
    Ma_san_pham     MA_TYPE, 
    Ma_don_hang     MA_TYPE,
    So_luong        INT         DEFAULT 0   CHECK(So_luong >= 0),
    PRIMARY KEY(Ma_san_pham, Ma_don_hang)
    
    /*
    CONSTRAINT MSP_FKEY
        FOREIGN KEY (Ma_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    CONSTRAINT MDH_FKEY 
        FOREIGN KEY (Ma_don_hang) REFERENCES DON_HANG(Ma_don_hang)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    */
);

CREATE TABLE AP_MA
(
    Ma_don_hang     MA_TYPE,
    Ma_phieu        MA_TYPE,
    PRIMARY KEY (Ma_don_hang, Ma_phieu)
    /*
    CONSTRAINT MDH_FKEY
        FOREIGN KEY (Ma_don_hang) REFERENCES DON_HANG(Ma_don_hang)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    CONSTRAINT AP_MA_MP_FKEY
        FOREIGN KEY (Ma_phieu) REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    */
);

PRINT '>>> END CREAT TABLE';

GO

PRINT '>>> BEGIN INSERT DATA';

INSERT INTO CONG_TY_SAN_XUAT
(Quoc_gia, Giay_phep_kinh_doanh, Ten_cong_ty, Dia_chi, Ma_so_thue)
VALUES
(N'Việt Nam',  N'GP-123456',   N'Công ty Dược Phẩm An Khang',     N'Q1, TPHCM',        '0123456789'),
(N'Việt Nam',  N'GP-987654',   N'Công ty TNHH Meditech',         N'Cầu Giấy, Hà Nội', '1234567890'),
(N'Mỹ',        N'FDA-556677',  N'HealthPlus Manufacturing Inc.', N'New York',         '2345678901'),
(N'Hàn Quốc',  N'KFDA-112233', N'Korea Pharma Co., Ltd.',        N'Seoul',            '3456789012'),
(N'Đức',       N'EU-998877',   N'Bayer Healthcare GmbH',         N'Berlin',           '4567890123');


INSERT INTO THUONG_HIEU (Ma_so, Ten_thuong_hieu, Xuat_xu)
VALUES
('TH0000001', N'An Khang',       N'Việt Nam'),
('TH0000002', N'MediCare',       N'Nhật Bản'),
('TH0000003', N'HealthPlus',     N'Hoa Kỳ'),
('TH0000004', N'Samsung Health', N'Hàn Quốc'),
('TH0000005', N'Bayer',          N'Đức');


INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES
/* Nguoi mua hàng */
('ND0000001', N'Nguyễn Văn An',    '0912345678', 'M',  '1995-04-12', '8f7a1c0fe2a9b9234d8a9c12abf23cdd'),
('ND0000002', N'Trần Thị Hoa',     '0987654321', 'F',   '1990-09-22', '91bc120a44f2dcd00a712e3efab9c1e8'),
('ND0000003', N'Lê Minh Huy',      '0901122334', 'M',  '2000-01-15', 'bc12eeac9987d331a087654ff239dd77'),
('ND0000004', N'Phạm Ngọc Lan',    '0933445566', 'F',   '1998-07-03', 'af9921cd0033e1bc567aae991234abcd'),
('ND0000005', N'Hoàng Gia Bảo',    '0977889900', 'M',  '1999-11-28', 'cc10ab99ff883122bb55ddee004412aa'),


/* Nhan vien */
('ND0000006', N'Nguyen Huynh Van An', '0912345678', 'M', '1995-03-12', 'a1b2c3d4e5f6g7h8i9j0'),
('ND0000007', N'Tran Thi Bich Ngo', '0987654321', 'F', '1998-07-25', 'b2c3d4e5f6g7h8i9j0a1'),
('ND0000008', N'Le Van Cuong', '0901122334', 'M', '2000-11-05', 'c3d4e5f6g7h8i9j0a1b2'),
('ND0000009', N'Pham Thi Dao', '0934455667', 'F', '1992-02-18', 'd4e5f6g7h8i9j0a1b2c3'),
('ND0000010', N'Hoang Van Em', '0977788990', 'M', '1988-09-09', 'e5f6g7h8i9j0a1b2c3d4'),
('ND0000011', N'Nguyen Thi Hoa', '0911223344', 'F', '1996-12-01', 'f6g7h8i9j0a1b2c3d4e5'),
('ND0000012', N'Do Van Hung', '0945566778', 'M', '1990-05-15', 'g7h8i9j0a1b2c3d4e5f6'),
('ND0000013', N'Bui Thi Lan', '0923344556', 'F', '1999-08-20', 'h8i9j0a1b2c3d4e5f6g7'),
('ND0000014', N'Vo Van Minh', '0956677889', 'M', '1985-01-30', 'i9j0a1b2c3d4e5f6g7h8'),
('ND0000015', N'Nguyen Thi Nga', '0932233445', 'F', '1997-04-10', 'j0a1b2c3d4e5f6g7h8i9'),
('ND0000016', N'Tran Van *****', '0967788991', 'M', '1994-06-22', 'a2b3c4d5e6f7g8h9i0j1'),
('ND0000017', N'Pham Thi Quyen', '0913344556', 'F', '1991-10-14', 'b3c4d5e6f7g8h9i0j1a2'),
('ND0000018', N'Le Van Son', '0982233445', 'M', '1989-12-25', 'c4d5e6f7g8h9i0j1a2b3'),
('ND0000019', N'Nguyen Thi Thao', '0925566778', 'F', '1993-03-03', 'd5e6f7g8h9i0j1a2b3c4'),
('ND0000020', N'Hoang Van Tien', '0978899001', 'M', '1990-07-07', 'e6f7g8h9i0j1a2b3c4d5'),
('ND0000021', N'Do Thi Uyen', '0914455667', 'F', '1995-09-19', 'f7g8h9i0j1a2b3c4d5e6'),
('ND0000022', N'Bui Van Vinh', '0942233445', 'M', '1987-11-11', 'g8h9i0j1a2b3c4d5e6f7'),
('ND0000023', N'Vo Thi Xuan', '0936677889', 'F', '1992-01-01', 'h9i0j1a2b3c4d5e6f7g8'),
('ND0000024', N'Nguyen Van Yen', '0953344556', 'M', '1986-05-05', 'i0j1a2b3c4d5e6f7g8h9'),
('ND0000025', N'Tran Thi Anh', '0987788992', 'F', '1999-02-28', 'j1a2b3c4d5e6f7g8h9i0'),
('ND0000026', N'Le Van Bao', '0912233445', 'M', '1994-08-08', 'a3b4c5d6e7f8g9h0i1j2'),
('ND0000027', N'Pham Thi Cam', '0925566779', 'F', '1993-12-12', 'b4c5d6e7f8g9h0i1j2a3'),
('ND0000028', N'Hoang Van Dung', '0978899002', 'M', '1988-04-04', 'c5d6e7f8g9h0i1j2a3b4'),
('ND0000029', N'Nguyen Thi Hanh', '0943344556', 'F', '1996-06-16', 'd6e7f8g9h0i1j2a3b4c5'),
('ND0000030', N'Do Van Khoa', '0937788993', 'M', '1991-09-09', 'e7f8g9h0i1j2a3b4c5d6'),
('ND0000031', N'Bui Thi Lien', '0952233445', 'F', '1990-11-21', 'f8g9h0i1j2a3b4c5d6e7'),
('ND0000032', N'Vo Van Nam', '0986677889', 'M', '1985-02-02', 'g9h0i1j2a3b4c5d6e7f8'),
('ND0000033', N'Nguyen Thi Oanh', '0917788994', 'F', '1997-07-07', 'h0i1j2a3b4c5d6e7f8g9'),
('ND0000034', N'Tran Van Phuong', '0928899003', 'M', '1992-10-10', 'i1j2a3b4c5d6e7f8g9h0'),
('ND0000035', N'Pham Thi Quynh', '0972233445', 'F', '1995-12-31', 'j2a3b4c5d6e7f8g9h0i1')
;

-- QUANG CAO --
INSERT INTO QUANG_CAO (Ma_quang_cao, File_qc, Nen_tang, Muc_hieu_qua, Thoi_gian_dang_ky, Thoi_gian_het_han, Chi_phi)
VALUES
('QC0000001', './banner_fb1.png',      'facebook', 40, '2025-01-01 08:00', '2025-02-01 08:00', 600000.00),
('QC0000002', './video_tiktok1.mp4',   'tiktok',   20, '2025-01-05 10:00', '2025-03-05 10:00', 1500000.00),
('QC0000003', './preroll_yt1.mp4',     'youtube',  10, '2025-01-10 09:00', '2025-02-28 09:00', 950000.00),
('QC0000004', './story_ig1.jpg',       'instagram', 11, '2025-01-15 12:30', '2025-02-15 12:30', 420000.00),
('QC0000005', './banner_fb2.png',      'facebook', 25, '2025-02-01 07:30', '2025-03-01 07:30', 700000.00),
('QC0000006', './video_tiktok2.mp4',   'tiktok',   0, '2025-02-10 14:00', '2025-04-10 14:00', 1300000.00),
('QC0000007', './preroll_yt2.mp4',     'youtube',  0, '2025-02-20 16:00', '2025-03-20 16:00', 820000.00),
('QC0000008', './story_ig2.jpg',       'instagram', 0, '2025-03-01 09:00', '2025-04-01 09:00', 380000.00),
('QC0000009', './banner_fb3.png',      'facebook', 4,  '2025-03-05 11:00', '2025-04-05 11:00', 300000.00),
('QC0000010', './video_tiktok3.mp4',   'tiktok',   6, '2025-03-10 13:00', '2025-05-10 13:00', 1800000.00);

-- DANH MUC --
INSERT INTO DANH_MUC(Ten, Ten_danh_muc_cha)
VALUES
(N'Thực Phẩm Chức Năng', NULL),
(N'Vitamin & Khoáng chất', N'Thực Phẩm Chức NNăng' ),
(N'Hỗ Trợ Điều Trị', N'Thực Phẩm Chức Năng'),
(N'Hỗ Trợ Làm Đẹp',  N'Thực Phẩm Chức Năng'),
(N'Sinh Lý - Nội Tiết Tố', N'Thực Phẩm Chức Năng'),
(N'Thuốc',NULL),
(N'Thuốc Dị ứng', N'Thuốc'),
(N'Thuốc Ung thư', N'Thuốc'),
(N'Thuốc Kháng sinh, Kháng nấm', N'Thuốc'),
(N'Thuốc Tiết Niệu - Sinh Dục', N'Thuốc'),
(N'Thiết Bị Y Tế', NULL),
(N'Dược Mỹ Phẩm', NULL),
(N'Chăm Sóc Cá Nhân', NULL)
;

/* DON VI GIAO HANG */ 
INSERT INTO DON_VI_GIAO_HANG
	(Ma_don_vi_giao_hang, So_luong_don_da_giao)
VALUES
	('DVGH00001', 1),
	('DVGH00002', 7),
	('DVGH00003', 20),
	('DVGH00004', 46),
	('DVGH00005', 111),
	('DVGH00006', 23),
	('DVGH00007', 161),
	('DVGH00008', 314),
	('DVGH00009', 9),
	('DVGH00010', 10),
	('DVGH00011', 278),
	('DVGH00012', 82),
	('DVGH00013', 90),
	('DVGH00014', 145),
	('DVGH00015', 61),
	('DVGH00016', 10);

INSERT INTO HOP_DONG (
    Thoi_han_hop_dong, Van_ban_hop_dong, Ma_so_thue_cong_ty
)
VALUES
(12,  N'Hợp đồng cung ứng số 01', '0123456789'),
(24,  N'Hợp đồng phân phối số 02', '1234567890'),
(36,  N'Hợp đồng hợp tác số 03',   '2345678901'),
(18,  N'Hợp đồng nhập khẩu số 04', '3456789012'),
(48,  N'Hợp đồng độc quyền số 05','4567890123');

INSERT INTO NGUOI_MUA_HANG (Ma_so_nguoi_mua_hang, Dia_chi_mac_dinh)
VALUES
('ND0000001', N'Q1, TPHCM'),
('ND0000002', N'Cầu Giấy, Hà Nội'),
('ND0000003', N'Đống Đa, Hà Nội'),
('ND0000004', N'Tân Bình, TPHCM'),
('ND0000005', N'Hải Châu, Đà Nẵng');

INSERT INTO DIA_CHI (Ma_so_nguoi_dung, Dia_chi)
VALUES
('ND0000001', N'Q1, TPHCM'),
('ND0000001', N'Bình Thạnh, TPHCM'),


('ND0000002', N'Cầu Giấy, Hà Nội'),
('ND0000002', N'Nam Từ Liêm, Hà Nội'),


('ND0000003', N'Đống Đa, Hà Nội'),
('ND0000003', N'Thanh Xuân, Hà Nội'),


('ND0000004', N'Tân Bình, TPHCM'),
('ND0000004', N'Phú Nhuận, TPHCM'),


('ND0000005', N'Hải Châu, Đà Nẵng'),
('ND0000005', N'Thanh Khê, Đà Nẵng');

INSERT INTO NHAN_VIEN
(Ma_so_nhan_vien,  So_dinh_danh, Ngay_bat_dau_lam_viec, Luong, Anh_nhan_vien, Email, Thuong_them, Nganh_nghe, Ngay_lam_viec)
VALUES
/* Duoc si */
('ND0000006', '000123456789', '2020-01-15' , 15000000, N'an1.jpg', N'an1@example.com', 2000000, 'DUOC_SI', 6),
('ND0000007', '000987654321', '2020-01-15' ,12000000, N'an2.jpg', N'hoa@example.com', 1500000, 'DUOC_SI', 5),
('ND0000008', '001122334455', '2020-01-15' ,10000000, N'an3.jpg', N'huy@example.com', 1000000, 'DUOC_SI', 5),
('ND0000009', '009988776655', '2020-01-15' ,9000000, N'an4.jpg', N'lan@example.com',  500000, 'DUOC_SI', 6),
('ND0000010','004455667788','2020-01-15' ,11000000, N'an5.jpg', N'bao@example.com', 1200000, 'DUOC_SI', 7),


-- ND0000011 - ND0000014 + ND0000025 : NHAN_VIEN_CHUYEN_MON
('ND0000025', '123456789010', '2020-01-15', 12000000, N'anh_nv10.jpg', N'nv10@example.com', 2000000, 'NHAN_VIEN_CHUYEN_MON', 5),
('ND0000011', '123456789011', '2021-03-20', 10000000, N'anh_nv11.jpg', N'nv11@example.com', 1500000, 'NHAN_VIEN_CHUYEN_MON', 6),
('ND0000012', '123456789012', '2019-07-10', 9000000, N'anh_nv12.jpg', N'nv12@example.com', 1000000, 'NHAN_VIEN_CHUYEN_MON', 4),
('ND0000013', '123456789013', '2022-05-01', 11000000, N'anh_nv13.jpg', N'nv13@example.com', 2500000, 'NHAN_VIEN_CHUYEN_MON', 3),
('ND0000014', '123456789014', '2020-09-12', 9500000, N'anh_nv14.jpg', N'nv14@example.com', 1200000, 'NHAN_VIEN_CHUYEN_MON', 2),


-- ND0000015 - ND0000019 : NHAN_VIEN_MARKETING
('ND0000015', '123456789015', '2018-11-11', 11500000, N'anh_nv15.jpg', N'nv15@example.com', 1800000, 'NHAN_VIEN_MARKETING', 7),
('ND0000016', '123456789016', '2021-06-06', 10500000, N'anh_nv16.jpg', N'nv16@example.com', 1700000, 'NHAN_VIEN_MARKETING', 5),
('ND0000017', '123456789017', '2019-02-02', 9800000, N'anh_nv17.jpg', N'nv17@example.com', 1300000, 'NHAN_VIEN_MARKETING', 6),
('ND0000018', '123456789018', '2020-08-08', 10200000, N'anh_nv18.jpg', N'nv18@example.com', 1400000, 'NHAN_VIEN_MARKETING', 4),
('ND0000019', '123456789019', '2022-01-01', 10800000, N'anh_nv19.jpg', N'nv19@example.com', 1600000, 'NHAN_VIEN_MARKETING', 3),


-- ND0000020 - ND0000024 : NHAN_VIEN_GIAO_HANG
('ND0000020', '123456789020', '2017-04-04', 12500000, N'anh_nv20.jpg', N'nv20@example.com', 2200000, 'NHAN_VIEN_GIAO_HANG', 2),
('ND0000021', '123456789021', '2019-12-12', 9700000, N'anh_nv21.jpg', N'nv21@example.com', 1100000, 'NHAN_VIEN_GIAO_HANG', 7),
('ND0000022', '123456789022', '2020-10-10', 10100000, N'anh_nv22.jpg', N'nv22@example.com', 1500000, 'NHAN_VIEN_GIAO_HANG', 5),
('ND0000023', '123456789023', '2021-07-07', 9900000, N'anh_nv23.jpg', N'nv23@example.com', 1250000, 'NHAN_VIEN_GIAO_HANG', 6),
('ND0000024', '123456789024', '2018-03-03', 11200000, N'anh_nv24.jpg', N'nv24@example.com', 1900000, 'NHAN_VIEN_GIAO_HANG', 4);

INSERT INTO NHAN_VIEN_CHUYEN_MON
    (Ma_so_nhan_vien, Bang_cap, Mo_ta, Chuyen_khoa, Kinh_nghiem, Chuc_danh)
VALUES
    ('ND0000010', N'Dược sĩ đại học', N'Chuyên tư vấn thuốc kê đơn', N'Dược lâm sàng',  N'5 năm kinh nghiệm', N'Dược sĩ'),
    ('ND0000011', N'Dược sĩ đại học', N'', N'Dược lý', N'3 năm kinh nghiệm', N'Dược sĩ'),
    ('ND0000012', N'Thạc sĩ Dược', N'Nghiên cứu công thức thuốc', N'Hóa dược', N'7 năm kinh nghiệm', N'Dược sĩ trưởng'),
    ('ND0000013', N'Dược sĩ trung cấp', N'Phụ trách kho thuốc', N'Kho thuốc', N'4 năm kinh nghiệm', N'Nhân viên kho'),
    ('ND0000014', N'Dược sĩ đại học', N'', N'Bào chế', N'6 năm kinh nghiệm', N'Dược sĩ');

INSERT INTO SAN_PHAM
(Ma_so_san_pham, Ten_san_pham, Luu_y, Gia_tien, Loai_san_pham, Don_vi_tinh,
 Quy_cach, Mo_ta_ngan, Xuat_xu, Ma_so_thue_cong_ty, Tac_dung_phu,
 Ma_so_thuong_hieu, Ten_danh_muc, Cong_dung, Cach_dung, Bao_quan,
 Ma_so_nhan_vien_kiem_duyet)
VALUES
-- 1–5: THUỐC (Loai = 4)
('SP0000001', N'Thuốc A1', N'Lưu ý dùng theo toa.',      50000, 4, N'Hộp', N'10 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Điều trị A', N'Uống sau ăn', N'Nơi khô ráo', NULL),
('SP0000002', N'Thuốc A2', N'Không tự ý tăng liều.',     65000, 4, N'Hộp', N'10 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Hạ sốt', N'Uống khi cần', N'Nơi khô thoáng', NULL),
('SP0000003', N'Thuốc A3', NULL,                         75000, 4, N'Vỉ',  N'12 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Giảm đau', N'Uống sau ăn', N'Để xa ánh nắng',  NULL),
('SP0000004', N'Thuốc A4', NULL,                         89000, 4, N'Hộp', N'20 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Kháng viêm', N'Uống 2 lần/ngày', N'Nơi khô ráo',NULL),
('SP0000005', N'Thuốc A5', NULL,                         99000, 4, N'Hộp', N'30 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Hỗ trợ miễn dịch', N'Uống sáng', N'Nhiệt độ phòng', NULL),

-- 6–10: CHĂM SÓC CÁ NHÂN (Loai = 5)
('SP0000006', N'Sản phẩm CS 1', NULL, 120000, 5, N'Chai', N'250ml', N'Sản phẩm tắm gội', N'VN', NULL, NULL, NULL, N'Chăm Sóc Cá Nhân', N'Làm sạch', N'Hướng dẫn trên bao bì', N'Nơi thoáng mát', NULL),
('SP0000007', N'Sản phẩm CS 2', NULL, 135000, 5, N'Chai', N'300ml', N'Sữa tắm', N'Thái Lan', NULL, NULL, NULL, N'Chăm Sóc Cá Nhân', N'Dưỡng ẩm', N'Dùng hằng ngày', N'Nơi khô ráo',  NULL),
('SP0000008', N'Sản phẩm CS 3', NULL, 99000, 5, N'Chai', N'200ml', N'Dầu gội', N'VN', NULL, NULL, NULL, N'Chăm Sóc Cá Nhân', N'Ngừa gàu', N'Dùng 2–3 lần/tuần', N'Nhiệt độ phòng',  NULL),
('SP0000009', N'Sản phẩm CS 4', NULL, 159000, 5, N'Tuýp', N'100g', N'Kem đánh răng', N'Mỹ', NULL, NULL, NULL, N'Chăm Sóc Cá Nhân', N'Làm trắng răng', N'Ngày 2 lần', N'Nơi thoáng',  NULL),
('SP0000010', N'Sản phẩm CS 5', NULL, 110000, 5, N'Chai', N'250ml', N'Sữa rửa mặt', N'Hàn Quốc', NULL, NULL, NULL, N'Chăm Sóc Cá Nhân', N'Làm sạch da', N'Sáng & tối', N'Nơi khô ráo', NULL),

-- 11–15: THIẾT BỊ Y TẾ (Loai = 1)
('SP0000011', N'TBYT 1', NULL, 250000, 1, N'Hộp', N'1 bộ', N'Dụng cụ đo', N'VN', NULL, NULL, NULL, N'Thiết Bị Y Tế', N'Đo huyết áp', N'Theo hướng dẫn', N'Nơi thoáng mát',  NULL),
('SP0000012', N'TBYT 2', NULL, 320000, 1, N'Hộp', N'1 bộ', N'Nhiệt kế điện tử', N'Mỹ', NULL, NULL, NULL, N'Thiết Bị Y Tế', N'Đo nhiệt độ', N'HDSD kèm theo', N'Nơi sạch sẽ',  NULL),
('SP0000013', N'TBYT 3', NULL, 180000, 1, N'Hộp', N'1 cái', N'Máy xông mũi', N'Nhật', NULL, NULL, NULL, N'Thiết Bị Y Tế', N'Hỗ trợ hô hấp', N'Dùng theo toa', N'Nhiệt độ phòng',  NULL),
('SP0000014', N'TBYT 4', NULL, 450000, 1, N'Hộp', N'1 cái', N'Máy đo đường huyết', N'Hàn Quốc', NULL, NULL, NULL, N'Thiết Bị Y Tế', N'Kiểm tra đường huyết', N'Dùng đúng liều test', N'Khô ráo', NULL),
('SP0000015', N'TBYT 5', NULL, 520000, 1, N'Hộp', N'1 cái', N'Máy xịt y tế', N'Đức', NULL, NULL, NULL, N'Thiết Bị Y Tế', N'Hỗ trợ điều trị', N'HDSD đính kèm', N'Nơi thoáng',NULL),

-- 16–20: THỰC PHẨM CHỨC NĂNG (Loai = 2)
('SP0000016', N'TPCN 1', NULL, 150000, 2, N'Hộp', N'60 viên', N'Bổ sung vitamin', N'Mỹ', NULL, NULL, NULL, N'Thực Phẩm Chức Năng', N'Tăng đề kháng', N'Uống sáng', N'Nhiệt độ phòng', NULL),
('SP0000017', N'TPCN 2', NULL, 220000, 2, N'Hộp', N'30 viên', N'Bổ não', N'Anh', NULL, NULL, NULL, N'Thực Phẩm Chức Năng', N'Hỗ trợ trí nhớ', N'Uống sau ăn', N'Khô ráo',  NULL),
('SP0000018', N'TPCN 3', NULL, 190000, 2, N'Hộp', N'100 viên', N'Bổ xương khớp', N'Úc', NULL, NULL, NULL, N'Thực Phẩm Chức Năng', N'Hỗ trợ xương', N'Uống hằng ngày', N'Nơi thoáng', NULL),
('SP0000019', N'TPCN 4', NULL, 265000, 2, N'Hộp', N'50 viên', N'Bổ máu', N'VN', NULL, NULL, NULL, N'Thực Phẩm Chức Năng', N'Hỗ trợ tuần hoàn', N'Uống sáng tối', N'Khô ráo',  NULL),
('SP0000020', N'TPCN 5', NULL, 210000, 2, N'Hộp', N'30 viên', N'Collagen', N'Hàn Quốc', NULL, NULL, NULL, N'Thực Phẩm Chức Năng', N'Làm đẹp da', N'Uống buổi tối', N'Nơi mát', NULL),

-- 21–25: DƯỢC MỸ PHẨM (Loai = 3)
('SP0000021', N'DMP 1', NULL, 180000, 3, N'Tuýp', N'50ml', N'Kem dưỡng da', N'Pháp', NULL, NULL, NULL, N'Dược Mỹ Phẩm', N'Dưỡng ẩm', N'Dùng buổi tối', N'Nơi thoáng', NULL),
('SP0000022', N'DMP 2', NULL, 230000, 3, N'Chai',  N'100ml', N'Nước hoa hồng', N'Pháp', NULL, NULL, NULL, N'Dược Mỹ Phẩm', N'Cân bằng da', N'Dùng sau rửa mặt', N'Khô ráo', NULL),
('SP0000023', N'DMP 3', NULL, 199000, 3, N'Tuýp', N'40ml', N'Kem chống nắng', N'Hàn Quốc', NULL, NULL, NULL, N'Dược Mỹ Phẩm', N'Chống UV', N'Trước khi ra nắng', N'Nhiệt độ phòng', NULL),
('SP0000024', N'DMP 4', NULL, 260000, 3, N'Chai',  N'30ml', N'Serum C', N'Mỹ', NULL, NULL, NULL, N'Dược Mỹ Phẩm', N'Sáng da', N'2–3 giọt/ngày', N'Nơi mát', NULL),
('SP0000025', N'DMP 5', NULL, 330000, 3, N'Chai',  N'50ml', N'Serum Retinol', N'Canada', NULL, NULL, NULL, N'Dược Mỹ Phẩm', N'Tái tạo da', N'Dùng buổi tối', N'Khô ráo', NULL)


;

-- CHI NHANH --
INSERT INTO CHI_NHANH
(Ma_chi_nhanh, Trang_thai, Dien_thoai, Dia_chi, Ten_chi_nhanh,
 Thoi_gian_mo_cua, Thoi_gian_dong_cua, Ngay_lam_viec, Ma_so_duoc_si_quan_ly)
VALUES
('CN0000001', 'O', '0912345678', '12 Nguyen Trai, Q1', 'Chi nhanh Quan 1',
 '08:00', '21:00', 6, NULL),


('CN0000002', 'O', '0987654321', '45 Le Loi, Q3', 'Chi nhanh Quan 3',
 '07:30', '20:30', 6, NULL),


('CN0000003', 'C', '0901122334', '89 Cach Mang Thang 8', 'Chi nhanh CMT8',
 '09:00', '18:00', 5, NULL),


('CN0000004', 'O', '0933445566', '22 Phan Xich Long', 'Chi nhanh Phan Xich Long',
 '08:00', '22:00', 6, NULL),


('CN0000005', 'O', '0977223344', '101 Tran Hung Dao', 'Chi nhanh Tran Hung Dao',
 '07:00', '19:00', 6, NULL),


('CN0000006', 'C', '0905566778', '56 Nguyen Thi Minh Khai', 'Chi nhanh NTMK',
 '10:00', '17:00', 4, NULL),


('CN0000007', 'O', '0911998877', '33 Vo Thi Sau', 'Chi nhanh Vo Thi Sau',
 '08:00', '20:00', 6, NULL),


('CN0000008', 'O', '0922334455', '77 Dien Bien Phu', 'Chi nhanh DBP',
 '08:30', '21:30', 6, NULL),


('CN0000009', 'C', '0939887766', '09 Quang Trung, Go Vap', 'Chi nhanh Go Vap',
 '09:00', '17:00', 5, NULL),


('CN0000010', 'O', '0944556677', '150 Le Van Sy', 'Chi nhanh Le Van Sy',
 '08:00', '21:00', 6, NULL);

-- PHIEU GIAM GIA --
INSERT INTO PHIEU_GIAM_GIA
(Ma_phieu, Loai_ma_giam_gia, Thoi_gian_bat_dau_hieu_luc, Thoi_gian_het_hieu_luc,
 So_luong_ma, Gia_don_hang_toi_thieu, Loai_giam_phan_tram_tien,
 Do_uu_tien, Cho_don_cho_san_pham, Ma_so_nguoi_so_huu)
VALUES
('PGG000001', 'V', '2025-01-01 00:00', '2025-02-01 23:59',
 100, 200000.00, 'P', 1, 'D', NULL),


('PGG000002', 'T', '2025-01-10 08:00', '2025-03-10 23:59',
 50, 300000.00, 'P', 2, 'D', NULL),


('PGG000003', 'V', '2025-02-01 00:00', '2025-04-01 00:00',
 200, 150000.00, 'P', 1, 'S', NULL),


('PGG000004', 'V', '2025-01-15 10:00', '2025-02-28 23:59',
 500, 0.00, 'P', 3, 'D', NULL),


('PGG000005', 'T', '2025-02-20 00:00', '2025-05-20 23:59',
 80, 250000.00, 'P', 1, 'S', NULL),


('PGG000006', 'V', '2025-03-01 00:00', '2025-04-15 23:59',
 150, 100000.00, 'P', 2, 'D', NULL),


('PGG000007', 'V', '2025-03-10 00:00', '2025-04-10 23:59',
 300, 0.00, 'P', 4, 'D', NULL),


('PGG000008', 'T', '2025-01-05 12:00', '2025-02-05 12:00',
 60, 350000.00, 'T', 2, 'S', NULL),


('PGG000009', 'T', '2025-04-01 00:00', '2025-06-01 23:59',
 120, 120000.00, 'T', 3, 'D', NULL),


('PGG000010', 'T', '2025-02-25 00:00', '2025-03-25 23:59',
 40, 500000.00, 'T', 5, 'S', NULL),


('PGG000011', 'T', '2025-01-01 00:00', '2025-03-01 23:59', 100, 200000.00, 'T', 1, 'D', NULL),


('PGG000012', 'T', '2025-01-10 08:00', '2025-02-28 23:59', 80, 150000.00, 'T', 2, 'S', NULL),


('PGG000013', 'V', '2025-01-15 00:00', '2025-03-15 23:59', 120, 300000.00, 'T', 1, 'D', NULL),


('PGG000014', 'T', '2025-02-01 00:00', '2025-04-01 23:59', 60, 250000.00, 'T', 3, 'S', NULL),


('PGG000015', 'V', '2025-02-05 00:00', '2025-04-05 23:59', 200, 100000.00, 'T', 2, 'D', NULL),


('PGG000016', 'T', '2025-02-10 00:00', '2025-03-20 23:59', 90, 180000.00, 'T', 1, 'D', NULL),


('PGG000017', 'V', '2025-02-15 00:00', '2025-05-01 23:59', 300, 0.00, 'P', 4, 'D', NULL),


('PGG000018', 'T', '2025-03-01 00:00', '2025-04-30 23:59', 50, 350000.00, 'T', 5, 'S', NULL),


('PGG000019', 'V', '2025-03-05 00:00', '2025-05-05 23:59', 75, 120000.00, 'P', 3, 'D', NULL),


('PGG000020', 'T', '2025-03-10 00:00', '2025-04-20 23:59', 40, 500000.00, 'T', 2, 'S', NULL),


('PGG000021', 'V', '2025-03-15 00:00', '2025-06-01 23:59', 150, 200000.00, 'P', 1, 'D', NULL),


('PGG000022', 'T', '2025-03-20 00:00', '2025-05-20 23:59', 30, 300000.00, 'T', 2, 'S', NULL),


('PGG000023', 'V', '2025-03-25 00:00', '2025-06-25 23:59', 180, 100000.00, 'P', 5, 'D', NULL),


('PGG000024', 'T', '2025-04-01 00:00', '2025-05-31 23:59', 100, 400000.00, 'T', 4, 'S', NULL),


('PGG000025', 'V', '2025-04-05 00:00', '2025-07-05 23:59', 210, 0.00, 'P', 3, 'D', NULL),


('PGG000026', 'T', '2025-04-10 00:00', '2025-06-10 23:59', 55, 220000.00, 'T', 2, 'S', NULL),


('PGG000027', 'V', '2025-04-15 00:00', '2025-08-01 23:59', 130, 250000.00, 'P', 1, 'D', NULL),


('PGG000028', 'T', '2025-04-20 00:00', '2025-06-20 23:59', 70, 500000.00, 'T', 5, 'S', NULL),


('PGG000029', 'V', '2025-05-01 00:00', '2025-07-30 23:59', 300, 150000.00, 'P', 3, 'D', NULL),


('PGG000030', 'T', '2025-05-05 00:00', '2025-07-15 23:59', 45, 350000.00, 'T', 2, 'S', NULL);

INSERT INTO CONG_TY_GIAO_HANG
	(Ma_so_thue, Ten, Hop_dong, Ma_don_vi_giao_hang)
VALUES
    ('1234567890', N'GiaoNhanNhanh',    'HD0000001', 'DVGH00001'),
    ('2234567890', N'ShipVN',           'HD0000002', 'DVGH00002'),
    ('3234567890', N'SuperShip',        'HD0000003', 'DVGH00003'),
    ('4234567890', N'GHN Express',      'HD0000004', 'DVGH00004'),
    ('5234567890', N'VietShip',         'HD0000005', 'DVGH00005'),
    ('6234567890', N'VTPost',           'HD0000006', 'DVGH00006'),
    ('7234567890', N'QuanLyShip',       'HD0000007', 'DVGH00007'),
    ('8234567890', N'NhatTinLogistics', 'HD0000008', 'DVGH00008');


INSERT INTO DUOC_SI (Ma_so_nhan_vien, Ma_so_chi_nhanh_lam_viec) 
VALUES
('ND0000006', 'CNH000001'),
('ND0000007', 'CNH000002'),
('ND0000008', 'CNH000001'),
('ND0000009', 'CNH000003'),
('ND0000010', 'CNH000004');

INSERT INTO NHAN_VIEN_GIAO_HANG
    (Ma_so_nhan_vien, Bang_lai_xe, Ca_giao_hang, Ma_don_vi_giao_hang)
VALUES
    ('ND0000020', 'B12345678901', 'S', 'DVGH00001'),
    ('ND0000021', 'B12345678902', 'C', 'DVGH00002'),
    ('ND0000022', 'B12345678903', 'T', 'DVGH00003'),
    ('ND0000023', 'B12345678904', 'S', 'DVGH00004'),
    ('ND0000024', 'B12345678905', 'C', 'DVGH00005');


INSERT INTO NHAN_VIEN_MARKETING
    (Ma_so_nhan_vien, Kinh_nghiem, So_luot_tham_gia)
VALUES
    ('ND0000015', N'1 năm digital marketing', 3),
    ('ND0000016', N'2 năm tối ưu quảng cáo', 5),
    ('ND0000017', N'Chạy ads Facebook',      2),
    ('ND0000018', N'Viết content dược',      6),
    ('ND0000019', N'Quản lý chiến dịch',     4);

INSERT INTO YEU_CAU_TU_VAN
    (Ma_tu_van, Noi_dung_hoi, So_dien_thoai, Trang_thai, Ho_ten_nguoi_duoc_tu_van, Ma_nhan_vien_kiem_duyet, Ma_nguoi_mua_hang)
VALUES
('TV0000001', N'Tôi muốn tư vấn về thuốc hạ sốt cho trẻ em', '0912345678', 0, N'Nguyen Van An', 'ND0000011', 'ND0000001'),
('TV0000002', N'Tư vấn sản phẩm bổ sung vitamin C', '0987654321', 1, N'Tran Thi Bich', 'ND0000011', 'ND0000002'),
('TV0000003', N'Hỏi về thuốc kháng sinh phù hợp', '0901122334', 2, N'Le Van Cuong', 'ND0000012', 'ND0000003'),
('TV0000004', N'Tư vấn thuốc giảm đau an toàn', '0934455667', 3, N'Pham Thi Dao', 'ND0000013', 'ND0000004'),
('TV0000005', N'Tôi muốn biết thêm về thuốc ho cho trẻ nhỏ', '0977788990', 0, N'Hoang Van Em', 'ND0000014', 'ND0000005');

INSERT INTO CAU_HOI
    (So_thu_tu, Ma_so_san_pham, Noi_dung, Luot_like, Thoi_gian_hoi, Ma_nguoi_dung_tra_loi)
VALUES
(1, 'SP0000001', N'Thuốc này có tác dụng phụ không?', 5, '2025-11-01 10:15:00', 'ND0000001'),
(2, 'SP0000002', N'Sản phẩm này dùng cho trẻ em được không?', 3, '2025-11-02 14:30:00', 'ND0000001'),
(3, 'SP0000003', N'Tôi có thể uống thuốc này sau bữa ăn không?', 7, '2025-11-03 09:45:00', 'ND0000002'),
(4, 'SP0000004', N'Sản phẩm này bảo quản như thế nào?', 2, '2025-11-04 16:20:00', 'ND0000003'),
(5, 'SP0000005', N'Thuốc này có cần đơn bác sĩ không?', 4, '2025-11-05 11:10:00', 'ND0000004');

INSERT INTO THUOC
    (Ma_so_san_pham, Loai_thuoc, Mui_vi_Mui_huong, Chi_dinh, Thanh_phan, Giay_cong_bo_san_pham, Doi_tuong_su_dung, Dang_bao_che, So_dang_ki)
VALUES
('SP0000001', 0, N'Không mùi', N'Hạ sốt, giảm đau', N'Paracetamol 500mg', N'GCN001', N'Người lớn và trẻ em trên 6 tuổi', N'Viên nén', 'SDK0000000001'),
('SP0000002', 1, N'Cam ngọt', N'Bổ sung vitamin C', N'Vitamin C 1000mg', N'GCN002', N'Người lớn', N'Viên sủi', 'SDK0000000002'),
('SP0000003', 0, N'Không mùi', N'Kháng sinh phổ rộng', N'Amoxicillin 500mg', N'GCN003', N'Người lớn', N'Viên nang', 'SDK0000000003'),
('SP0000004', 1, N'Dâu tây', N'Giảm ho, long đờm', N'Dextromethorphan, Guaifenesin', N'GCN004', N'Trẻ em trên 2 tuổi', N'Siro', 'SDK0000000004'),
('SP0000005', 0, N'Không mùi', N'Điều trị viêm loét dạ dày', N'Omeprazole 20mg', N'GCN005', N'Người lớn', N'Viên nang', 'SDK0000000005');

INSERT INTO CHAM_SOC_CA_NHAN
    (Ma_so_san_pham, Loai_da, Mui_vi_Mui_huong, Chi_dinh, Doi_tuong_su_dung)
VALUES
('SP0000006', N'Da dầu', N'Trái cây tươi', N'Làm sạch sâu, kiểm soát nhờn', N'Nam và nữ trưởng thành'),
('SP0000007', N'Da khô', N'Hoa hồng', N'Dưỡng ẩm, làm mềm da', N'Nữ trưởng thành'),
('SP0000008', N'Da nhạy cảm', N'Không mùi', N'Làm dịu da, giảm kích ứng', N'Trẻ em và người lớn'),
('SP0000009', N'Da hỗn hợp', N'Trà xanh', N'Chống oxy hóa, bảo vệ da', N'Nam và nữ'),
('SP0000010', N'Mọi loại da', N'Lavender', N'Chống nắng, bảo vệ da khỏi tia UV', N'Người lớn');

INSERT INTO THIET_BI_Y_TE (Ma_so_san_pham)
VALUES
('SP0000011'),
('SP0000012'),
('SP0000013'),
('SP0000014'),
('SP0000015');

INSERT INTO THUC_PHAM_CHUC_NANG
    (Ma_so_san_pham, Chi_dinh, Thanh_phan, Giay_cong_bo_san_pham, Mui_vi_huong_vi, Dang_bao_che, Doi_tuong_su_dung, So_dang_ki)
VALUES
('SP0000016', N'Tăng cường sức đề kháng', N'Vitamin C, Kẽm', N'GCN_TPCN001', N'Cam', N'Viên sủi', N'Người lớn', 'TPCN00001'),
('SP0000017', N'Hỗ trợ tiêu hóa', N'Men vi sinh, chất xơ', N'GCN_TPCN002', N'Chuối', N'Bột hòa tan', N'Trẻ em và người lớn', 'TPCN00002'),
('SP0000018', N'Bổ sung canxi cho xương', N'Canxi, Vitamin D3', N'GCN_TPCN003', N'Không mùi', N'Viên nén', N'Người lớn tuổi', 'TPCN00003'),
('SP0000019', N'Hỗ trợ giấc ngủ', N'Melatonin, L-theanine', N'GCN_TPCN004', N'Lavender', N'Viên nang', N'Người lớn', 'TPCN00004'),
('SP0000020', N'Tăng cường trí nhớ', N'Omega-3, DHA', N'GCN_TPCN005', N'Dầu cá', N'Viên nang mềm', N'Sinh viên, người làm việc trí óc', 'TPCN00005');

INSERT INTO DUOC_MY_PHAM
    (Ma_so_san_pham, Loai_da, Chi_dinh, Thanh_phan, Giay_cong_bo_san_pham, Doi_tuong_su_dung, So_dang_ki)
VALUES
('SP0000021', N'Da dầu', N'Ngừa mụn, kiểm soát nhờn', N'Salicylic Acid, Niacinamide', N'GCN_DMP001', N'Thanh thiếu niên và người lớn', 21001),
('SP0000022', N'Da khô', N'Dưỡng ẩm sâu', N'Hyaluronic Acid, Glycerin', N'GCN_DMP002', N'Nữ trưởng thành', 21002),
('SP0000023', N'Da nhạy cảm', N'Làm dịu da, giảm kích ứng', N'Aloe Vera, Panthenol', N'GCN_DMP003', N'Trẻ em và người lớn', 21003),
('SP0000024', N'Da hỗn hợp', N'Chống lão hóa, làm sáng da', N'Vitamin C, Retinol', N'GCN_DMP004', N'Người lớn', 21004),
('SP0000025', N'Mọi loại da', N'Chống nắng, bảo vệ da khỏi tia UV', N'Zinc Oxide, Titanium Dioxide', N'GCN_DMP005', N'Nam và nữ', 21005);

INSERT INTO ANH_SAN_PHAM (Ma_so_san_pham, Anh_san_pham)
VALUES
('SP0000001', N'paracetamol_front.jpg'),
('SP0000001', N'paracetamol_back.jpg'),
('SP0000007', N'cream_box.jpg'),
('SP0000012', N'blood_pressure_monitor.jpg'),
('SP0000020', N'omega3_capsules.jpg');

INSERT INTO GOM_QC_SP (Ma_san_pham, Ma_quang_cao)
VALUES
('SP0000001', 'QC0000001'),
('SP0000002', 'QC0000002'),
('SP0000003', 'QC0000003'),
('SP0000004', 'QC0000004'),
('SP0000005', 'QC0000005')
;

INSERT INTO AP_DUNG (Ma_so_san_pham, Ma_phieu)
VALUES
('SP0000001', 'PGG000001'),
('SP0000002', 'PGG000002'),
('SP0000003', 'PGG000003'),
('SP0000004', 'PGG000004'),
('SP0000005', 'PGG000005')
;

INSERT INTO DON_HANG
(
    Ma_don_hang, Ma_so_nguoi_mua_hang, Ma_don_vi_giao_hang, Trang_thai_don_hang,
    Phuong_thuc_thanh_toan, Thoi_gian_dat_hang, Thoi_gian_ban_giao,
    Thoi_gian_ban_giao_du_kien, Ho_ten_nguoi_nhan, So_dien_thoai_nguoi_nhan,
    Dia_chi_nhan, Phi_van_chuyen, Ma_chi_nhanh_quan_ly
)
VALUES 
('DH0000001', 'ND0000001', 'DVGH00001', 0, 0,
 '2025-01-01 08:30:00', NULL,
 '2025-01-02 17:00:00', N'Nguyen Van A', '0912345678',
 N'123 Le Loi, Q1', 15000, 'CN0000001'),


('DH0000002', 'ND0000002', 'DVGH00002', 1, 1,
 '2025-01-02 09:10:00', NULL,
 '2025-01-03 18:00:00', N'Tran Thi B', '0987654321',
 N'45 Hai Ba Trung, Q3', 20000, 'CN0000002'),


('DH0000003', 'ND0000003', 'DVGH00003', 2, 2,
 '2025-01-03 10:00:00', '2025-01-04 11:30:00',
 '2025-01-04 18:00:00', N'Le Minh C', '0933333333',
 N'12 Nguyen Hue, Q1', 30000, 'CN0000003'),


('DH0000004', 'ND0000004', 'DVGH00004', 3, 3,
 '2025-01-04 14:20:00', NULL,
 '2025-01-05 17:00:00', N'Pham Hoai D', '0966666666',
 N'89 Tran Phu, Q5', 25000, 'CN0000004'),


('DH0000005', 'ND0000005', 'DVGH00005', 4, 4,
 '2025-01-05 16:00:00', '2025-01-06 15:00:00',
 '2025-01-06 19:00:00', N'Ho Phuong E', '0977777777',
 N'67 CMT8, Q10', 10000, 'CN0000005'),


('DH0000006', 'ND0000001', 'DVGH00006', 1, 5,
 '2025-01-06 08:45:00', NULL,
 '2025-01-07 17:00:00', N'Dang Hoai F', '0922222222',
 N'22 Lac Long Quan, Q11', 15000, 'CN0000006'),


('DH0000007', 'ND0000002', 'DVGH00007', 0, 6,
 '2025-01-07 12:00:00', NULL,
 '2025-01-08 18:00:00', N'Ton That G', '0955555555',
 N'9 Ly Thuong Kiet, Q5', 18000, 'CN0000007'),


('DH0000008', 'ND0000003', 'DVGH00008', 2, 2,
 '2025-01-08 13:10:00', '2025-01-09 09:30:00',
 '2025-01-09 20:00:00', N'Vo Dinh H', '0944444444',
 N'321 Nguyen Trai, Q1', 12000, 'CN0000008');

INSERT INTO ANH_CHI_NHANH
(Ma_chi_nhanh, Anh_chi_nhanh)
VALUES
('CN0000001', './img/cn1_front.jpg'),
('CN0000001', './img/cn1_inside1.jpg'),


('CN0000002', './img/cn2_front.jpg'),
('CN0000002', './img/cn2_shelves.jpg'),


('CN0000003', './img/cn3_front.jpg'),
('CN0000003', './img/cn3_counter.jpg'),


('CN0000004', './img/cn4_front.jpg'),
('CN0000004', './img/cn4_storage.jpg'),


('CN0000005', './img/cn5_front.jpg'),
('CN0000005', './img/cn5_staff.jpg');

-- GIAM GIA PHAN TRAM --
INSERT INTO GIAM_GIA_PHAN_TRAM
(Ma_phieu, Phan_tram_giam, So_tien_giam_toi_da)
VALUES
('PGG000001', 0.05, 30000.00),   -- 5%  tối đa 30k
('PGG000002', 0.10, 50000.00),   -- 10% tối đa 50k
('PGG000003', 0.12, 60000.00),   -- 12% tối đa 60k
('PGG000004', 0.15, 70000.00),   -- 15% tối đa 70k
('PGG000005', 0.20, 80000.00),   -- 20% tối đa 80k
('PGG000006', 0.25, 100000.00),  -- 25% tối đa 100k
('PGG000007', 0.30, 120000.00),  -- 30% tối đa 120k
('PGG000008', 0.35, 150000.00)  -- 35% tối đa 150k
/*
('PGG000019', 0.40, 200000.00),  -- 40% tối đa 200k
('PGG000020', 0.50, 250000.00)  -- 50% tối đa 250k
*/
;

/* PHIEU GIAM GIA TIEN */
INSERT INTO GIAM_GIA_TIEN
	(Ma_phieu, So_tien_giam)
VALUES
	('PGG000009', 5000.00),
	('PGG000010', 10000.00),
	('PGG000011', 20000.00),
	('PGG000012', 40000.00),
	('PGG000013', 50000.00),
	('PGG000014', 80000.00),
	('PGG000015', 100000.00),
	('PGG000016', 150000.00);

INSERT INTO THAM_GIA
    (Ma_so_nhan_vien, Ma_quang_cao)
VALUES
    ('ND0000017', 'QC0000001'),
    ('ND0000018', 'QC0000002'),
    ('ND0000017', 'QC0000003'),
    ('ND0000019', 'QC0000004'),
    ('ND0000019', 'QC0000005'),
    ('ND0000015', 'QC0000006'),
    ('ND0000016', 'QC0000007'),
    ('ND0000017', 'QC0000008');

INSERT INTO ANH_TU_VAN (Ma_tu_van, Anh_tu_van)
VALUES
('TV0000001', N'tuvan_tv000001_image1.jpg'),
('TV0000001', N'tuvan_tv000001_image2.jpg'),
('TV0000002', N'tuvan_tv000002_image1.jpg'),
('TV0000003', N'tuvan_tv000003_image1.jpg'),
('TV0000005', N'tuvan_tv000005_image1.jpg');

INSERT INTO GOM_TV_SP (Ma_tu_van, Ma_san_pham)
VALUES
('TV0000001', 'SP0000001'),
('TV0000002', 'SP0000002'),
('TV0000003', 'SP0000003'),
('TV0000004', 'SP0000004'),
('TV0000005', 'SP0000005');

INSERT INTO CAU_TRA_LOI
(So_thu_tu, So_thu_tu_cau_hoi, Ma_so_san_pham, Noi_dung, Luot_like, Thoi_gian_tra_loi, Ma_nguoi_mua_dat_cau_hoi)
VALUES
(1, 1, 'SP0000001', N'Thuốc này có thể gây buồn ngủ nhẹ, nên uống vào buổi tối.', 3, '2025-11-06 09:00:00', 'ND000010'),
(2, 2, 'SP0000002', N'Sản phẩm vitamin C có thể dùng cho trẻ em trên 6 tuổi.', 5, '2025-11-06 10:15:00', 'ND000011'),
(3, 3, 'SP0000003', N'Thuốc kháng sinh nên uống sau bữa ăn để giảm kích ứng dạ dày.', 2, '2025-11-06 11:30:00', 'ND000012'),
(4, 4, 'SP0000004', N'Siro ho cần bảo quản nơi khô ráo, tránh ánh nắng trực tiếp.', 4, '2025-11-06 14:00:00', 'ND000013'),
(5, 5, 'SP0000005', N'Thuốc dạ dày này cần đơn bác sĩ để đảm bảo an toàn.', 6, '2025-11-06 15:45:00', 'ND000014');

INSERT INTO DANH_GIA
(So_thu_tu, Ma_so_san_pham, Noi_dung, Thoi_gian_danh_gia, So_sao, Ma_so_nguoi_mua_hang, Ma_don_dat_hang)
VALUES
(1, 'SP0000001', N'Sản phẩm tốt, hiệu quả nhanh.', '2025-11-10 09:00:00', 5, 'ND0000001', 'DH0000001'),
(2, 'SP0000002', N'Viên sủi dễ uống, vị cam ngon.', '2025-11-11 10:30:00', 4, 'ND0000002', 'DH0000002'),
(3, 'SP0000003', N'Thuốc kháng sinh dùng ổn, nhưng hơi khó uống.', '2025-11-12 14:20:00', 3, 'ND0000003', 'DH0000003'),
(4, 'SP0000004', N'Siro ho cho bé rất hiệu quả, bé dễ uống.', '2025-11-13 08:45:00', 5, 'ND0000004', 'DH0000004'),
(5, 'SP0000005', N'Thuốc dạ dày có tác dụng tốt, cần đơn bác sĩ.', '2025-11-14 16:10:00', 4, 'ND0000005', 'DH0000005');

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES
('SP0000001', 'DH0000001', 2),
('SP0000002', 'DH0000002', 1),
('SP0000003', 'DH0000003', 3),
('SP0000004', 'DH0000004', 5),
('SP0000005', 'DH0000005', 4);

INSERT INTO AP_MA (Ma_don_hang, Ma_phieu)
VALUES
('DH0000001', 'PGG000001'),
('DH0000002', 'PGG000002'),
('DH0000003', 'PGG000003'),
('DH0000004', 'PGG000004'),
('DH0000005', 'PGG000005');

PRINT '>>> END INSERT DATA';

GO

PRINT '>>> BEGIN ALTER TABLE / ADD  CONSTRAINT';

-- Alter TABLE

/*
 *  TODO: Alter Table, add reference trigger, which can not create in
 *  CREATE TABLE.
 */

/* DANH MUC */
ALTER TABLE DANH_MUC
ADD CONSTRAINT TDMC_T_FKEY
        FOREIGN KEY (Ten_danh_muc_cha) REFERENCES DANH_MUC(Ten)
            ON DELETE NO ACTION
            ON UPDATE CASCADE;
            
          
/* CHI NHANH */
ALTER TABLE CHI_NHANH
ADD CONSTRAINT MSDSQL_FKEY
        FOREIGN KEY (Ma_so_duoc_si_quan_ly) REFERENCES DUOC_SI(Ma_so_nhan_vien)
            ON DELETE SET DEFAULT
            ON UPDATE CASCADE;

/* DUOC SI */
-- Circular Referencing
ALTER TABLE DUOC_SI
ADD CONSTRAINT FK_DS_CN FOREIGN KEY (Ma_so_chi_nhanh_lam_viec)
        REFERENCES CHI_NHANH(Ma_chi_nhanh)
            ON UPDATE CASCADE 
            ON DELETE SET NULL;

/* CAU HOI */
ALTER TABLE CAU_HOI
ADD CONSTRAINT CAU_HOI2ND_FK FOREIGN KEY (Ma_nguoi_dung_tra_loi) 
        REFERENCES NGUOI_DUNG(Ma_so)
            ON DELETE SET NULL 
            ON UPDATE CASCADE;

/* AP DUNG */
ALTER TABLE AP_DUNG
ADD CONSTRAINT FK_AP_SP FOREIGN KEY (Ma_so_san_pham)
        REFERENCES SAN_PHAM(Ma_so_san_pham)
           ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT FK_AP_PGG FOREIGN KEY (Ma_phieu)
        REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

/* GOM_TV_SP */
ALTER TABLE GOM_TV_SP
ADD CONSTRAINT GOM_TV_SP2TV FOREIGN KEY (Ma_tu_van) REFERENCES YEU_CAU_TU_VAN(Ma_tu_van)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT GOM_TV_SP2SP FOREIGN KEY (Ma_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
        ON DELETE CASCADE 
        ON UPDATE CASCADE;

/* CAU TRA LOI */
ALTER TABLE CAU_TRA_LOI
ADD CONSTRAINT CTL2CAUHOI_FK FOREIGN KEY (So_thu_tu_cau_hoi, Ma_so_san_pham)
        REFERENCES CAU_HOI(So_thu_tu, Ma_so_san_pham)
            ON DELETE CASCADE 
            ON UPDATE CASCADE,
            
    CONSTRAINT CTL2NGUOIDUNG_FK FOREIGN KEY (Ma_nguoi_mua_dat_cau_hoi)
        REFERENCES NGUOI_DUNG(Ma_so)
            ON DELETE CASCADE 
            ON UPDATE CASCADE;

/* DANH GIA */
ALTER TABLE DANH_GIA
ADD CONSTRAINT DANH_GIA2SP_FK FOREIGN KEY (Ma_so_san_pham) 
        REFERENCES SAN_PHAM(Ma_so_san_pham)
            ON DELETE CASCADE 
            ON UPDATE CASCADE,
        
    CONSTRAINT DANH_GIA2NMH_FK FOREIGN KEY (Ma_so_nguoi_mua_hang) 
        REFERENCES NGUOI_MUA_HANG(Ma_so_nguoi_mua_hang)
            ON DELETE SET NULL 
            ON UPDATE CASCADE,
        
    CONSTRAINT DANH_GIA2DON_HANG_FK FOREIGN KEY (Ma_don_dat_hang) 
        REFERENCES DON_HANG(Ma_don_hang)
            ON DELETE SET NULL 
            ON UPDATE CASCADE;

/* GOM SAN PHAM - DON HANG */
ALTER TABLE GOM_SP_DN
ADD CONSTRAINT MSP_FKEY
        FOREIGN KEY (Ma_san_pham) REFERENCES SAN_PHAM(Ma_so_san_pham)
            ON DELETE CASCADE
            ON UPDATE CASCADE,

    CONSTRAINT MDH_FKEY 
        FOREIGN KEY (Ma_don_hang) REFERENCES DON_HANG(Ma_don_hang)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

/* AP MA */
ALTER TABLE AP_MA
ADD CONSTRAINT MDH_FKEY
        FOREIGN KEY (Ma_don_hang) REFERENCES DON_HANG(Ma_don_hang)
            ON DELETE CASCADE
            ON UPDATE CASCADE,

    CONSTRAINT AP_MA_MP_FKEY
        FOREIGN KEY (Ma_phieu) REFERENCES PHIEU_GIAM_GIA(Ma_phieu)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

PRINT '>>> END ALTER TABLE/ END ADD CONSTRAINT';

GO

PRINT '>>> INSERT UPDATE DELETE PROCEDURE >>>'

GO
/* DON HANG/ INSERT */
CREATE OR ALTER PROCEDURE insertOrder
(
	@Ma_don_hang				MA_TYPE,
	@Ma_so_nguoi_mua_hang		MA_TYPE,
	@Ma_don_vi_giao_hang		MA_TYPE = NULL,
	@Trang_thai_don_hang		INT = 0,
	@Phuong_thuc_thanh_toan		INT = 0,
	@Thoi_gian_dat_hang			DATETIME = NULL,
	@Thoi_gian_ban_giao			DATETIME = NULL,
	@Thoi_gian_ban_giao_du_kien	DATETIME = NULL,
	@Ho_ten_nguoi_nhan			NVARCHAR(30),
	@So_dien_thoai_nguoi_nhan	SO_DIEN_THOAI_TYPE,
	@Dia_chi_nhan				DIA_CHI_TYPE,
	@Phi_van_chuyen				TIEN_TYPE = 0,
	@Ma_chi_nhanh_quan_ly		MA_TYPE = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY 

	    -- Primary key uniqueness
	    IF EXISTS (SELECT 1 FROM DON_HANG WHERE Ma_don_hang = @Ma_don_hang)
	    BEGIN
		    RAISERROR(N'Mã đơn hàng %s đã tồn tại!', 16, 1, @Ma_don_hang);
		    RETURN;
	    END

	    -- Check required fields
	    IF (@Ho_ten_nguoi_nhan IS NULL OR LTRIM(RTRIM(@Ho_ten_nguoi_nhan)) = '')
	    BEGIN
		    RAISERROR(N'Họ tên người nhận không được để trống.', 16, 1);
		    RETURN;
	    END

	    IF (@Dia_chi_nhan IS NULL OR LTRIM(RTRIM(@Dia_chi_nhan)) = '')
	    BEGIN
		    RAISERROR(N'Địa chỉ nhận hàng không được để trống.', 16, 1);
		    RETURN;
	    END

	    IF (@So_dien_thoai_nguoi_nhan IS NULL)
	    BEGIN
		    RAISERROR(N'Số điện thoại người nhận không được để trống.', 16, 1);
		    RETURN;
	    END
	    ELSE IF @So_dien_thoai_nguoi_nhan NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            RAISERROR(N'Số điện thoại chỉ bao gồm số.', 16, 1);
            RETURN;
        END

	    -- Check foreign keys exist
	    IF NOT EXISTS (SELECT 1 FROM NGUOI_MUA_HANG WHERE Ma_so_nguoi_mua_hang = @Ma_so_nguoi_mua_hang)
	    BEGIN
		    RAISERROR(N'Mã người mua hàng %s không tồn tại.', 16, 1, @Ma_so_nguoi_mua_hang);
		    RETURN;
	    END


	    IF @Ma_don_vi_giao_hang IS NOT NULL AND
	       NOT EXISTS (SELECT 1 FROM DON_VI_GIAO_HANG WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang)
	    BEGIN
		    RAISERROR(N'Đơn vị giao hàng %s không tồn tại.', 16, 1, @Ma_don_vi_giao_hang);
		    RETURN;
	    END


	    IF @Ma_chi_nhanh_quan_ly IS NOT NULL AND
	       NOT EXISTS (SELECT 1 FROM CHI_NHANH WHERE Ma_chi_nhanh = @Ma_chi_nhanh_quan_ly)
	    BEGIN
		    RAISERROR(N'Mã chi nhánh %s không tồn tại.', 16, 1, @Ma_chi_nhanh_quan_ly);
		    RETURN;
	    END


	    -- Check enumerations
	    IF @Trang_thai_don_hang NOT IN (0, 1, 2, 3, 4, 5)
	    BEGIN
		    RAISERROR(N'Trạng thái đơn hàng không hợp lệ.', 16, 1);
		    RETURN;
	    END


	    IF @Phuong_thuc_thanh_toan NOT IN (0, 1, 2, 3, 4, 5, 6)
	    BEGIN
		    RAISERROR(N'Phương thức thanh toán không hợp lệ.', 16, 1);
		    RETURN;
	    END


	    -- Time logic
	    IF @Thoi_gian_dat_hang IS NULL
		    SET @Thoi_gian_dat_hang = GETDATE();


    	IF @Thoi_gian_ban_giao_du_kien IS NULL
	    	SET @Thoi_gian_ban_giao_du_kien = DATEADD(day, 7, @Thoi_gian_dat_hang);


	    IF @Thoi_gian_ban_giao IS NOT NULL 
	       AND @Thoi_gian_ban_giao < @Thoi_gian_dat_hang
	    BEGIN
		    RAISERROR(N'Thời gian bàn giao không thể nhỏ hơn thời gian đặt hàng.', 16, 1);
		    RETURN;
	    END


	    IF @Thoi_gian_ban_giao_du_kien < @Thoi_gian_dat_hang
	    BEGIN
		    RAISERROR(N'Thời gian bàn giao dự kiến phải lớn hơn thời gian đặt hàng.', 16, 1);
		    RETURN;
	    END


	    -- Shipping fee
	    IF @Phi_van_chuyen < 0
	    BEGIN
		    RAISERROR(N'Phí vận chuyển không thể âm.', 16, 1);
		    RETURN;
	    END


	    -- Validated
	    INSERT INTO DON_HANG
	    (
		    Ma_don_hang, Ma_so_nguoi_mua_hang, Ma_don_vi_giao_hang,
		    Trang_thai_don_hang, Phuong_thuc_thanh_toan,
		    Thoi_gian_dat_hang, Thoi_gian_ban_giao, Thoi_gian_ban_giao_du_kien,
		    Ho_ten_nguoi_nhan, So_dien_thoai_nguoi_nhan, Dia_chi_nhan,
		    Phi_van_chuyen, Ma_chi_nhanh_quan_ly
	    )
	    VALUES
	    (
		    @Ma_don_hang, @Ma_so_nguoi_mua_hang, @Ma_don_vi_giao_hang,
		    @Trang_thai_don_hang, @Phuong_thuc_thanh_toan,
		    @Thoi_gian_dat_hang, @Thoi_gian_ban_giao, @Thoi_gian_ban_giao_du_kien,
		    @Ho_ten_nguoi_nhan, @So_dien_thoai_nguoi_nhan, @Dia_chi_nhan,
		    @Phi_van_chuyen, @Ma_chi_nhanh_quan_ly
	    );


	    PRINT N'Thêm đơn hàng thành công!';


    END TRY


    BEGIN CATCH
        DECLARE 
            @Err NVARCHAR(4000),
            @Severity INT;


        SELECT 
            @Err = ERROR_MESSAGE(),
            @Severity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi thêm đơn hàng: %s', @Severity, 1, @Err);
        RETURN;
    END CATCH
END

GO

/*

SELECT *
FROM DON_HANG

SELECT *
FROM NGUOI_MUA_HANG

SELECT *
FROM CHI_NHANH

GO

PRINT '===== INSERT ORDER TESTCASES ====='

GO

PRINT 'TEST 01'

*/

/* Valid Insertion*/

/*
EXEC insertOrder 
    @Ma_don_hang = 'DH0000010',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Nguyen Test',
    @So_dien_thoai_nguoi_nhan = '0900000000',
    @Dia_chi_nhan = N'1 Test Street, Q1',
    @Phi_van_chuyen = 10000,
    @Trang_thai_don_hang = 0,
    @Phuong_thuc_thanh_toan = 1,
    @Ma_chi_nhanh_quan_ly = 'CN0000001';
    

PRINT 'RESULT TEST 01'

SELECT *
FROM DON_HANG

GO

PRINT 'TEST 02'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000011',
    @Ma_so_nguoi_mua_hang = 'ND0000003',
    @Ma_don_vi_giao_hang = 'DVGH00003',
    @Trang_thai_don_hang = 2,
    @Phuong_thuc_thanh_toan = 2,
    @Thoi_gian_dat_hang = '2025-02-01 10:00:00',
    @Thoi_gian_ban_giao = '2025-02-02 11:00:00',
    @Thoi_gian_ban_giao_du_kien = '2025-02-02 18:00:00',
    @Ho_ten_nguoi_nhan = N'Pham Test',
    @So_dien_thoai_nguoi_nhan = '0911111111',
    @Dia_chi_nhan = N'123 ABC Street',
    @Phi_van_chuyen = 15000,
    @Ma_chi_nhanh_quan_ly = 'CN0000008';


PRINT 'RESULT TEST 02'

SELECT *
FROM DON_HANG

GO

PRINT 'TEST 03'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000012',
    @Ma_so_nguoi_mua_hang = 'ND0000004',
    @Ma_don_vi_giao_hang = NULL,
    @Trang_thai_don_hang = 1,
    @Phuong_thuc_thanh_toan = 3,
    @Ho_ten_nguoi_nhan = N'Test Case 3',
    @So_dien_thoai_nguoi_nhan = '0920000000',
    @Dia_chi_nhan = N'Dia chi test',
    @Phi_van_chuyen = 5000,
    @Ma_chi_nhanh_quan_ly = 'CN0000010';

PRINT 'RESULT TEST 03'

SELECT *
FROM DON_HANG

GO

PRINT 'TEST 04'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000001',  -- already exists
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Duplicate PK',
    @So_dien_thoai_nguoi_nhan = '0901111111',
    @Dia_chi_nhan = N'Test';


PRINT 'RESULT TEST 04'

SELECT *
FROM DON_HANG

GO
PRINT 'TEST 05'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000013',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Invalid Phone',
    @So_dien_thoai_nguoi_nhan = '12345ABC',   -- contains letters
    @Dia_chi_nhan = N'Test address';

PRINT 'RESULT TEST 05'
SELECT *
FROM DON_HANG

GO

PRINT 'TEST 05'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000014',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Trang_thai_don_hang = 99,   -- invalid
    @Phuong_thuc_thanh_toan = 1,
    @Ho_ten_nguoi_nhan = N'Invalid Status',
    @So_dien_thoai_nguoi_nhan = '0909999999',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 06'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000015',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Trang_thai_don_hang = 1,
    @Phuong_thuc_thanh_toan = 99,   -- invalid
    @Ho_ten_nguoi_nhan = N'Invalid Payment',
    @So_dien_thoai_nguoi_nhan = '0908888888',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 07'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000016',
    @Ma_so_nguoi_mua_hang = 'ND9999999',  -- does NOT exist
    @Ho_ten_nguoi_nhan = N'No Buyer',
    @So_dien_thoai_nguoi_nhan = '0907777777',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 08'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000017',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ma_don_vi_giao_hang = 'DVGH99999',  -- not exist
    @Ho_ten_nguoi_nhan = N'Invalid DVGH',
    @So_dien_thoai_nguoi_nhan = '0906666666',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 09'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000018',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Invalid Branch',
    @So_dien_thoai_nguoi_nhan = '0903333333',
    @Dia_chi_nhan = N'Test',
    @Ma_chi_nhanh_quan_ly = 'CN9999999';  -- not exist
    
GO

PRINT 'TEST 10'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000019',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'    ',  -- empty
    @So_dien_thoai_nguoi_nhan = '0902222222',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 11'

EXEC insertOrder 
    @Ma_don_hang = 'DH0000020',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Test',
    @So_dien_thoai_nguoi_nhan = '0901111111',
    @Dia_chi_nhan = N'';  -- invalid
    
GO

PRINT 'TEST 12'
EXEC insertOrder 
    @Ma_don_hang = 'DH0000021',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Ho_ten_nguoi_nhan = N'Negative Fee',
    @So_dien_thoai_nguoi_nhan = '0901212121',
    @Dia_chi_nhan = N'Test',
    @Phi_van_chuyen = -1;  -- invalid
    
GO

PRINT 'TEST 13'
EXEC insertOrder 
    @Ma_don_hang = 'DH0000022',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Thoi_gian_dat_hang = '2025-02-01 10:00:00',
    @Thoi_gian_ban_giao = '2025-01-31 10:00:00', -- invalid
    @Ho_ten_nguoi_nhan = N'Time Error',
    @So_dien_thoai_nguoi_nhan = '0905555555',
    @Dia_chi_nhan = N'Test';
    
GO

PRINT 'TEST 14'
EXEC insertOrder 
    @Ma_don_hang = 'DH0000023',
    @Ma_so_nguoi_mua_hang = 'ND0000002',
    @Thoi_gian_dat_hang = '2025-02-05 09:00:00',
    @Thoi_gian_ban_giao_du_kien = '2025-02-04 09:00:00',  -- invalid
    @Ho_ten_nguoi_nhan = N'Est Wrong',
    @So_dien_thoai_nguoi_nhan = '0915151515',
    @Dia_chi_nhan = N'Test';
    
GO


SELECT *
FROM DON_HANG


PRINT '===== END INSERT ORDER TESTCASES ====='

*/

GO

/* DON HANG/ UPDATE */
CREATE OR ALTER PROCEDURE updateOrder
(
    @Ma_don_hang                MA_TYPE,
    @Ma_so_nguoi_mua_hang       MA_TYPE = NULL,
    @Ma_don_vi_giao_hang        MA_TYPE = NULL,
    @Trang_thai_don_hang        INT = NULL,
    @Phuong_thuc_thanh_toan     INT = NULL,
    @Thoi_gian_dat_hang         DATETIME = NULL,
    @Thoi_gian_ban_giao         DATETIME = NULL,
    @Thoi_gian_ban_giao_du_kien DATETIME = NULL,
    @Ho_ten_nguoi_nhan          NVARCHAR(30) = NULL,
    @So_dien_thoai_nguoi_nhan   SO_DIEN_THOAI_TYPE = NULL,
    @Dia_chi_nhan               DIA_CHI_TYPE = NULL,
    @Phi_van_chuyen             TIEN_TYPE = NULL,
    @Ma_chi_nhanh_quan_ly       MA_TYPE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
        -- Check that the order exists
        IF NOT EXISTS (SELECT 1
                       FROM DON_HANG
                       WHERE Ma_don_hang = @Ma_don_hang)
        BEGIN
            RAISERROR(N'Mã đơn hàng %s không tồn tại!', 16, 1, @Ma_don_hang);
            RETURN;
        END


	    -- Check required fields
	    IF @Ho_ten_nguoi_nhan IS NOT NULL AND
	       LTRIM(RTRIM(@Ho_ten_nguoi_nhan)) = ''
	    BEGIN
		    RAISERROR(N'Họ tên người nhận không được để trống.', 16, 1);
		    RETURN;
	    END


	    IF @Dia_chi_nhan IS NOT NULL AND
	       LTRIM(RTRIM(@Dia_chi_nhan)) = ''
	    BEGIN
		    RAISERROR(N'Địa chỉ nhận hàng không được để trống.', 16, 1);
		    RETURN;
	    END


        IF @So_dien_thoai_nguoi_nhan IS NOT NULL AND
           @So_dien_thoai_nguoi_nhan NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            RAISERROR(N'Số điện thoại chỉ bao gồm số.', 16, 1);
            RETURN;
        END


	    -- Check update foreign key
        IF @Ma_so_nguoi_mua_hang IS NOT NULL AND
	       NOT EXISTS (SELECT 1
                       FROM NGUOI_MUA_HANG
                       WHERE Ma_so_nguoi_mua_hang = @Ma_so_nguoi_mua_hang)
        BEGIN
            RAISERROR(N'Mã số người mua hàng %s không tồn tại!', 16, 1, @Ma_so_nguoi_mua_hang);
            RETURN;
        END


        IF @Ma_don_vi_giao_hang IS NOT NULL AND
	       NOT EXISTS (SELECT 1
                       FROM DON_VI_GIAO_HANG
                       WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang)
        BEGIN
            RAISERROR(N'Mã số đơn vị giao hàng %s không tồn tại!', 16, 1, @Ma_so_nguoi_mua_hang);
            RETURN;
        END


        IF @Ma_chi_nhanh_quan_ly IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM CHI_NHANH
                           WHERE Ma_chi_nhanh = @Ma_chi_nhanh_quan_ly)
        BEGIN
            RAISERROR(N'Chi nhánh quản lý không tồn tại!', 16, 1);
            RETURN;
        END


        -- Validate status and payment method
        IF @Trang_thai_don_hang IS NOT NULL AND 
           @Trang_thai_don_hang NOT IN (0, 1, 2, 3, 4, 5)
        BEGIN
            RAISERROR(N'Trạng thái đơn hàng không hợp lệ!', 16, 1);
            RETURN;
        END


        IF @Phuong_thuc_thanh_toan IS NOT NULL AND 
           @Phuong_thuc_thanh_toan NOT IN (0, 1, 2, 3, 4, 5, 6)
        BEGIN
            RAISERROR(N'Phương thức thanh toán không hợp lệ!', 16, 1);
            RETURN;
        END


        -- Validate date logic
	    IF @Thoi_gian_dat_hang IS NOT NULL AND
	       @Thoi_gian_dat_hang > GETDATE()
	    BEGIN
		    RAISERROR(N'Thời gian đặt hàng không hợp lệ.', 16, 1)
	    END


	    DECLARE @latest_Thoi_gian_dat_hang DATETIME;
	    DECLARE @latest_Thoi_gian_ban_giao DATETIME;
	    DECLARE @latest_Thoi_gian_ban_giao_du_kien DATETIME;


	    IF @Thoi_gian_dat_hang IS NOT NULL
	    BEGIN
		    SET @latest_Thoi_gian_dat_hang = @Thoi_gian_dat_hang
	    END
	    ELSE
	    BEGIN
		    SELECT	@latest_Thoi_gian_dat_hang = Thoi_gian_dat_hang 
		    FROM	DON_HANG
		    WHERE	Ma_don_hang = @Ma_don_hang
	    END


	    IF @Thoi_gian_ban_giao IS NOT NULL
	    BEGIN
		    SET @latest_Thoi_gian_ban_giao = @Thoi_gian_ban_giao
	    END
	    ELSE
	    BEGIN
		    SELECT	@latest_Thoi_gian_ban_giao = Thoi_gian_ban_giao 
		    FROM	DON_HANG
		    WHERE	Ma_don_hang = @Ma_don_hang
	    END


	    IF @Thoi_gian_ban_giao_du_kien IS NOT NULL
	    BEGIN
		    SET @latest_Thoi_gian_ban_giao_du_kien = @Thoi_gian_ban_giao_du_kien
	    END
	    ELSE
	    BEGIN
		    SELECT	@latest_Thoi_gian_ban_giao_du_kien = Thoi_gian_ban_giao_du_kien
		    FROM	DON_HANG
		    WHERE	Ma_don_hang = @Ma_don_hang
	    END


        IF @latest_Thoi_gian_ban_giao < @latest_Thoi_gian_dat_hang
        BEGIN
            RAISERROR(N'Thời gian bàn giao không thể nhỏ hơn thời gian đặt hàng!', 16, 1);
            RETURN;
        END


        IF @latest_Thoi_gian_ban_giao_du_kien < @latest_Thoi_gian_dat_hang
        BEGIN
            RAISERROR(N'Thời gian bàn giao dự kiến không thể nhỏ hơn thời gian đặt hàng!', 16, 1);
            RETURN;
        END


        IF @Trang_thai_don_hang = 3 AND @latest_Thoi_gian_ban_giao IS NULL
        BEGIN
            RAISERROR(N'Đơn hàng trạng thái "đã giao" phải có thời gian bàn giao!', 16, 1);
            RETURN;
        END


	    -- Check shipping fee
        IF @Phi_van_chuyen IS NOT NULL AND
	       @Phi_van_chuyen < 0
	    BEGIN
		    RAISERROR(N'Phí vận chuyển không thể âm.', 16, 1)
	    END


        -- Validated
        UPDATE DON_HANG
        SET
            Ma_so_nguoi_mua_hang        = COALESCE(@Ma_so_nguoi_mua_hang, Ma_so_nguoi_mua_hang),
            Ma_don_vi_giao_hang         = COALESCE(@Ma_don_vi_giao_hang, Ma_don_vi_giao_hang),
            Trang_thai_don_hang         = COALESCE(@Trang_thai_don_hang, Trang_thai_don_hang),
            Phuong_thuc_thanh_toan      = COALESCE(@Phuong_thuc_thanh_toan, Phuong_thuc_thanh_toan),
            Thoi_gian_dat_hang          = COALESCE(@Thoi_gian_dat_hang, Thoi_gian_dat_hang),
            Thoi_gian_ban_giao          = COALESCE(@Thoi_gian_ban_giao, Thoi_gian_ban_giao),
            Thoi_gian_ban_giao_du_kien  = COALESCE(@Thoi_gian_ban_giao_du_kien, Thoi_gian_ban_giao_du_kien),
            Ho_ten_nguoi_nhan           = COALESCE(@Ho_ten_nguoi_nhan, Ho_ten_nguoi_nhan),
            So_dien_thoai_nguoi_nhan    = COALESCE(@So_dien_thoai_nguoi_nhan, So_dien_thoai_nguoi_nhan),
            Dia_chi_nhan                = COALESCE(@Dia_chi_nhan, Dia_chi_nhan),
            Phi_van_chuyen              = COALESCE(@Phi_van_chuyen, Phi_van_chuyen),
            Ma_chi_nhanh_quan_ly        = COALESCE(@Ma_chi_nhanh_quan_ly, Ma_chi_nhanh_quan_ly)
        WHERE Ma_don_hang = @Ma_don_hang;


        PRINT N'Cập nhật đơn hàng thành công.';
    END TRY


    BEGIN CATCH
        DECLARE 
            @Err NVARCHAR(4000),
            @Severity INT;


        SELECT 
            @Err = ERROR_MESSAGE(),
            @Severity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi cập nhật đơn hàng: %s', @Severity, 1, @Err);
        RETURN;
    END CATCH
END

GO

/*
PRINT '===== BEGIN UPDATE ORDER TESTCASES ====='

PRINT 'TEST.NO 1'
EXEC updateOrder
    @Ma_don_hang = 'DH0000001',
    @Ho_ten_nguoi_nhan = N'Nguyen Van Updated',
    @Phi_van_chuyen = 20000;
    
    
SELECT * FROM DON_HANG WHERE Ma_don_hang='DH0000001';
PRINT 'END TEST NO.1'
GO

PRINT 'TEST.NO 2'
EXEC updateOrder
    @Ma_don_hang = 'DH9999999',
    @Ho_ten_nguoi_nhan = N'Test';
PRINT 'END TEST NO.2'
GO

PRINT 'TEST.NO 3'
EXEC updateOrder
    @Ma_don_hang = 'DH0000002',
    @Ma_so_nguoi_mua_hang = 'ND9999999';
PRINT 'END TEST NO.3'
GO

PRINT 'TEST.NO 4'
EXEC updateOrder
    @Ma_don_hang = 'DH0000003',
    @Ma_don_vi_giao_hang = 'DVGH99999';
PRINT 'END TEST NO.4'
GO

PRINT 'TEST.NO 5'
EXEC updateOrder
    @Ma_don_hang = 'DH0000004',
    @Ho_ten_nguoi_nhan = N'   ';
PRINT 'END TEST NO.5'
GO

PRINT 'TEST.NO 6'
EXEC updateOrder
    @Ma_don_hang = 'DH0000005',
    @So_dien_thoai_nguoi_nhan = '09ABC67890';
PRINT 'END TEST NO.6'
GO

PRINT 'TEST.NO 7'
EXEC updateOrder
    @Ma_don_hang = 'DH0000006',
    @Trang_thai_don_hang = 99;
PRINT 'END TEST NO.7'
GO

PRINT 'TEST.NO 8'
EXEC updateOrder
    @Ma_don_hang = 'DH0000007',
    @Phuong_thuc_thanh_toan = 10;
PRINT 'END TEST NO.8'
GO

PRINT 'TEST.NO 9'
EXEC updateOrder
    @Ma_don_hang = 'DH0000008',
    @Thoi_gian_ban_giao = '2025-01-01';   -- invalid
PRINT 'END TEST NO.9'
GO

PRINT 'TEST.NO 10'
EXEC updateOrder
    @Ma_don_hang = 'DH0000010',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_ban_giao = NULL;
PRINT 'END TEST NO.10'
GO

PRINT 'TEST.NO 11'
EXEC updateOrder
    @Ma_don_hang = 'DH0000011',
    @Phi_van_chuyen = -1000;
PRINT 'END TEST NO.11'
GO

PRINT 'TEST.NO 12'
EXEC updateOrder
    @Ma_don_hang = 'DH0000012',
    @Ma_don_vi_giao_hang = 'DVGH00001',
    @Ho_ten_nguoi_nhan = N'Updated Receiver';
SELECT * FROM DON_HANG WHERE Ma_don_hang='DH0000012';
PRINT 'END TEST NO.12'
GO

PRINT '===== END UPDATE ORDER TESTCASES ====='

*/


GO

/* DON HANG/ DELETE */
/* TTDH
 * 0 => Chua dat
 * 1 => Dang xu ly
 * 2 => Dang giao
 * 3 => Da giao
 * 4 => Da huy
 * 5 => Tra hang
 */
CREATE OR ALTER PROCEDURE deleteOrder
(
    @Ma_don_hang    MA_TYPE
)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate input
        IF (@Ma_don_hang IS NULL OR LTRIM(RTRIM(@Ma_don_hang)) = '')
        BEGIN
            RAISERROR (N'Mã đơn hàng không được để trống!', 16, 1);
            RETURN;
        END


        -- Check order exists
        IF NOT EXISTS (SELECT 1 
                       FROM DON_HANG 
                       WHERE Ma_don_hang = @Ma_don_hang)
        BEGIN
            RAISERROR (N'Không tồn tại đơn hàng có mã %s!', 16, 1, @Ma_don_hang);
            RETURN;
        END


        ------------------------------------------------------------
        -- Business rule: Only allow delete when order is
        --    - Đang xử lý (1)
        --    - Đã hủy (4)
	      --    - Chưa đặt (0)
        --  Meaning: order not yet delivered or returned or ordered
        ------------------------------------------------------------


        DECLARE @Trang_thai INT;


        SELECT @Trang_thai = Trang_thai_don_hang
        FROM DON_HANG
        WHERE Ma_don_hang = @Ma_don_hang;

        IF (@Trang_thai IN (2, 3, 5))  -- 2=Đang giao, 3=Đã giao, 5=Trả hàng
        BEGIN
            RAISERROR (
                N'Không thể xóa đơn hàng %s vì tình trạng đơn hàng không cho phép xóa!',
                16, 1, @Ma_don_hang
            );
            RETURN;
        END


        -- Perform delete
        DELETE FROM DON_HANG
        WHERE Ma_don_hang = @Ma_don_hang;

        PRINT N'Đã xóa thành công đơn hàng ' + @Ma_don_hang;
        
    END TRY


    BEGIN CATCH
        DECLARE 
            @Err NVARCHAR(4000),
            @Severity INT;


        SELECT 
            @Err = ERROR_MESSAGE(),
            @Severity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi xóa đơn hàng: %s', @Severity, 1, @Err);
        RETURN;
    END CATCH
    
END

GO
/*
SELECT *
FROM DON_HANG

GO

PRINT '===== BEGIN DELETE ORDER TESTCASES ====='

PRINT 'TEST.NO 1 -- NULL input'
EXEC deleteOrder NULL;
PRINT 'END TEST NO.1'
GO

PRINT 'TEST.NO 2 -- Empty string input'
EXEC deleteOrder '';
PRINT 'END TEST NO.2'
GO

PRINT 'TEST.NO 3 -- Delete non-existing order'
EXEC deleteOrder 'DH9999999';
PRINT 'END TEST NO.3'
GO

PRINT 'TEST.NO 4 -- Delete order DH0000001 (TT 0)'
EXEC deleteOrder 'DH0000001';
PRINT 'END TEST NO.4'
GO

PRINT 'TEST.NO 5 -- Delete order DH0000002 (TT 1)'
EXEC deleteOrder 'DH0000002';
PRINT 'END TEST NO.5'
GO

PRINT 'TEST.NO 6 -- Delete order DH0000005 (TT 4)'
EXEC deleteOrder 'DH0000005';
PRINT 'END TEST NO.6'
GO

PRINT 'TEST.NO 7 -- Delete order DH0000007 (TT 0)'
EXEC deleteOrder 'DH0000007';
PRINT 'END TEST NO.7'
GO

PRINT 'TEST.NO 8 -- Delete order DH0000010 (TT 0, no delivery unit)'
EXEC deleteOrder 'DH0000010';
PRINT 'END TEST NO.8'
GO

PRINT 'TEST.NO 9 -- Delete order DH0000012 (no delivery unit)'
EXEC deleteOrder 'DH0000012';
PRINT 'END TEST NO.9'
GO

PRINT 'TEST.NO 10 -- Delete order DH0000003 (TT 2 -> FAIL)'
EXEC deleteOrder 'DH0000003';
PRINT 'END TEST NO.10'
GO

PRINT 'TEST.NO 11 -- Delete order DH0000004 (TT 3 -> FAIL)'
EXEC deleteOrder 'DH0000004';
PRINT 'END TEST NO.11'
GO

PRINT 'TEST.NO 12 -- Delete order DH0000008 (TT 2 -> FAIL)'
EXEC deleteOrder 'DH0000008';
PRINT 'END TEST NO.12'
GO

PRINT 'TEST.NO 13 -- Delete order DH0000011 (no delivery unit)'
EXEC deleteOrder 'DH0000011';
PRINT 'END TEST NO.13'
GO

PRINT '===== END DELETE ORDER TESTCASES ====='


*/

GO
/* DON VI GIAO HANG/ INSERT */
CREATE OR ALTER PROCEDURE InsertDeliveryComp
(
    @Ma_don_vi_giao_hang   MA_TYPE,
    @So_luong_don_da_giao  INT = 0
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;


        -- Validate input
        IF (@Ma_don_vi_giao_hang IS NULL OR LTRIM(RTRIM(@Ma_don_vi_giao_hang)) = '')
        BEGIN
            RAISERROR(N'Mã đơn vị giao hàng không được để trống!', 16, 1);
            RETURN;
        END


        IF (@So_luong_don_da_giao < 0)
        BEGIN
            RAISERROR(N'Số lượng đơn đã giao phải >= 0!', 16, 1);
            RETURN;
        END


        -- Check PK uniqueness
        IF EXISTS (
            SELECT 1 FROM DON_VI_GIAO_HANG
            WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang
        )
        BEGIN
            RAISERROR(
                N'Đã tồn tại đơn vị giao hàng với mã %s!', 
                16, 1, @Ma_don_vi_giao_hang
            );
            RETURN;
        END


        -- Perform insert
        INSERT INTO DON_VI_GIAO_HANG (Ma_don_vi_giao_hang, So_luong_don_da_giao)
        VALUES (@Ma_don_vi_giao_hang, @So_luong_don_da_giao);


        PRINT N'Thêm mới đơn vị giao hàng thành công: ' + @Ma_don_vi_giao_hang;
    END TRY


    BEGIN CATCH
        DECLARE 
            @Err NVARCHAR(4000),
            @Severity INT;


        SELECT 
            @Err = ERROR_MESSAGE(),
            @Severity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi xóa đơn hàng: %s', @Severity, 1, @Err);
        RETURN;
    END CATCH
END



GO

/* DON VI GIAO HANG/ UPDATE */
-- only need to update (derived attr) So_luong_don_da_giao
-- => update via procedure (will be implemented in 2.2.2)


/* DON VI GIAO HANG/ DELETE */
CREATE OR ALTER PROCEDURE DeleteDeliveryComp
(
    @Ma_don_vi_giao_hang   MA_TYPE
)
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
        -- Validate input
        IF (@Ma_don_vi_giao_hang IS NULL OR LTRIM(RTRIM(@Ma_don_vi_giao_hang)) = '')
        BEGIN
            RAISERROR(N'Mã đơn vị giao hàng không được để trống!', 16, 1);
            RETURN;
        END


        -- Check PK uniqueness
        IF NOT EXISTS (
            SELECT 1 FROM DON_VI_GIAO_HANG
            WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang
        )
        BEGIN
            RAISERROR(
                N'Mã đơn vị giao hàng %s không tồn tại!', 
                16, 1, @Ma_don_vi_giao_hang
            );
            RETURN;
        END


	    DECLARE @So_luong_don_da_giao INT = 0;


	    SELECT @So_luong_don_da_giao = So_luong_don_da_giao
	    FROM DON_VI_GIAO_HANG
	    WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang;


	    IF @So_luong_don_da_giao > 0
	    BEGIN
		    RAISERROR(
			    N'Không thể xóa vì đơn vị giao hàng đã giao %d đơn.',
			    16, 1, @So_luong_don_da_giao 
		    )
	    END


        -- Perform delete
        DELETE FROM DON_VI_GIAO_HANG
        WHERE Ma_don_vi_giao_hang = @Ma_don_vi_giao_hang;


        PRINT N'Xóa đơn vị giao hàng thành công: ' + @Ma_don_vi_giao_hang;
    END TRY


    BEGIN CATCH
        DECLARE 
            @Err NVARCHAR(4000),
            @Severity INT;


        SELECT 
            @Err = ERROR_MESSAGE(),
            @Severity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi xóa đơn vị giao hàng: %s', @Severity, 1, @Err);
        RETURN;
    END CATCH
END


GO
/* THAM GIA/ INSERT */
CREATE OR ALTER PROCEDURE InsertParticipation
(
    @Ma_so_nhan_vien     MA_TYPE,
	  @Ma_quang_cao       MA_TYPE
)
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
        -- Validate emp must exist
        IF NOT EXISTS (
            SELECT 1
            FROM NHAN_VIEN
            WHERE Ma_so_nhan_vien = @Ma_so_nhan_vien
        )
        BEGIN
            RAISERROR(N'Mã số nhân viên %s không tồn tại.', 16, 1, @Ma_so_nhan_vien);
            RETURN;
        END


        -- Validate adv must exists
        IF NOT EXISTS (
            SELECT 1
            FROM QUANG_CAO
            WHERE Ma_quang_cao = @Ma_quang_cao
        )
        BEGIN
            RAISERROR(N'Mã quảng cáo không tồn tại: %s', 16, 1, @Ma_quang_cao);
            RETURN;
        END


        -- Uniqueness constraint
        IF EXISTS (
            SELECT 1
            FROM THAM_GIA
            WHERE 
                Ma_so_nhan_vien = @Ma_so_nhan_vien AND
                Ma_quang_cao = @Ma_quang_cao
        )
        BEGIN
            RAISERROR(N'Nhân viên %s đã có tham gia quảng cáo %s.', 16, 1, @Ma_so_nhan_vien, @Ma_quang_cao);
            RETURN;
        END


        PRINT N'Nhân viêN tham gia quảng cáo thành công.';


    END TRY


    BEGIN CATCH
        DECLARE 
            @ErrMsg NVARCHAR(4000),
            @ErrSeverity INT;


        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi thêm nhân viên tham gia vào quảng cáo: %s', @ErrSeverity, 1, @ErrMsg);
        RETURN;
    END CATCH
END

GO


/* THAM GIA/ UPDATE */
-- we dont change this binding frequently once we have created it


/* THAM GIA/ DELETE */
-- deleted through cascade when an adv activity is removed
-- when an emp is deleted => maybe no cascade cz we may need to know how many emps join this adv

GO

/*INSERT SAN PHAM*/
CREATE OR ALTER PROCEDURE PROC_INSERT_SAN_PHAM (
      @Ma_so_san_pham             MA_TYPE,
      @Ten_san_pham               NVARCHAR(50),

      @Luu_y                      NVARCHAR(100)  = NULL,
      @Gia_tien                   TIEN_TYPE      = NULL,
      @Loai_san_pham              INT,
      @Don_vi_tinh                NVARCHAR(10)   = NULL,
      @Quy_cach                   NVARCHAR(50)   = NULL,
      @Mo_ta_ngan                 NVARCHAR(200)  = NULL,
      @Xuat_xu                    NVARCHAR(50)   = NULL,
      @Ma_so_thue_cong_ty         MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu               NVARCHAR(200)  = NULL,
      @Ma_so_thuong_hieu          MA_TYPE        = NULL,
      @Ten_danh_muc               NVARCHAR(30)   = NULL,
      @Cong_dung                  NVARCHAR(200)  = NULL,
      @Cach_dung                  NVARCHAR(200)  = NULL,
      @Bao_quan                   NVARCHAR(200)  = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE        = NULL,
      @Trang_thai                 CHAR           = 'O'
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -------------------------------------------------------------
        -- 1. CHECK PK: Ma_so_san_pham must be unique
        -------------------------------------------------------------
        IF EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
        BEGIN
            RAISERROR(N'Ma_so_san_pham %s already exists.', 16, 1, @Ma_so_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 2. CHECK UNIQUE: Ten_san_pham must be unique
        -------------------------------------------------------------
        IF EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ten_san_pham = @Ten_san_pham)
        BEGIN
            RAISERROR(N'Ten_san_pham %s already exists.', 16, 1, @Ten_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 3. CHECK value: Gia_tien >= 0
        -------------------------------------------------------------
        IF @Gia_tien IS NOT NULL AND @Gia_tien < 0
        BEGIN
            DECLARE @Gia_tien_str NVARCHAR(20) = CONVERT(NVARCHAR(20),@Gia_tien);
        
            RAISERROR(N'Gia_tien %s must be >= 0.', 
                      16, 1, @Gia_tien_str);
            RETURN;
        END

        -------------------------------------------------------------
        -- 4. CHECK ENUM constraint: Loai_san_pham in (1..5)
        -------------------------------------------------------------
        IF @Loai_san_pham NOT IN (1,2,3,4,5)
        BEGIN
            RAISERROR(N'Loai_san_pham %d is invalid. Must be in (1 - THIET_BI_Y_TE, 2 - THUC_PHAM_CHUC_NANG ,3 - DUOC_MY_PHAM, 4 - THUOC , 5 - CHAM_SOC_CA_NHAN).', 
                      16, 1, @Loai_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 5. CHECK FK: Company exists
        -------------------------------------------------------------
        IF @Ma_so_thue_cong_ty IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM CONG_TY_SAN_XUAT WHERE Ma_so_thue = @Ma_so_thue_cong_ty)
        BEGIN
            RAISERROR(N'Ma_so_thue_cong_ty %s does not exist in CONG_TY_SAN_XUAT.',
                      16, 1, @Ma_so_thue_cong_ty);
            RETURN;
        END

        -------------------------------------------------------------
        -- 6. CHECK FK: Brand exists
        -------------------------------------------------------------
        IF @Ma_so_thuong_hieu IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM THUONG_HIEU WHERE Ma_so = @Ma_so_thuong_hieu)
        BEGIN
            RAISERROR(N'Ma_so_thuong_hieu %s does not exist in THUONG_HIEU.',
                      16, 1, @Ma_so_thuong_hieu);
            RETURN;
        END

        -------------------------------------------------------------
        -- 7. CHECK FK: Category exists
        -------------------------------------------------------------
        IF @Ten_danh_muc IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM DANH_MUC WHERE Ten = @Ten_danh_muc)
        BEGIN
            RAISERROR(N'Ten_danh_muc %s does not exist in DANH_MUC.',
                      16, 1, @Ten_danh_muc);
            RETURN;
        END

        -------------------------------------------------------------
        -- 8. CHECK FK: Specialist employee exists
        -------------------------------------------------------------
        IF @Ma_so_nhan_vien_kiem_duyet IS NOT NULL AND
           NOT EXISTS (
               SELECT 1 
               FROM NHAN_VIEN_CHUYEN_MON
               WHERE Ma_so_nhan_vien = @Ma_so_nhan_vien_kiem_duyet
           )
        BEGIN
            RAISERROR(N'Ma_so_nhan_vien_kiem_duyet %s does not exist in NHAN_VIEN_CHUYEN_MON.',
                      16, 1, @Ma_so_nhan_vien_kiem_duyet);
            RETURN;
        END
        
        IF @Trang_thai NOT IN ('O','S')
        BEGIN
            RAISERROR(N'Trang_thai %s is invalid. Must be in (O - Onself, S - Shutdown).', 
                      16, 1, @Loai_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 9. INSERT ROW
        -------------------------------------------------------------
        INSERT INTO SAN_PHAM (
            Ma_so_san_pham, Ten_san_pham, Luu_y, Gia_tien, Loai_san_pham,
            Don_vi_tinh, Quy_cach, Mo_ta_ngan, Xuat_xu, Ma_so_thue_cong_ty,
            Tac_dung_phu, Ma_so_thuong_hieu, Ten_danh_muc, Cong_dung,
            Cach_dung, Bao_quan, Ma_so_nhan_vien_kiem_duyet, Trang_thai
        )
        VALUES (
            @Ma_so_san_pham, @Ten_san_pham, @Luu_y, @Gia_tien, @Loai_san_pham,
            @Don_vi_tinh, @Quy_cach, @Mo_ta_ngan, @Xuat_xu, @Ma_so_thue_cong_ty,
            @Tac_dung_phu, @Ma_so_thuong_hieu, @Ten_danh_muc, @Cong_dung,
            @Cach_dung, @Bao_quan,@Ma_so_nhan_vien_kiem_duyet, @Trang_thai
        );
        
    END TRY

    BEGIN CATCH
    
      DECLARE 
        @ErrMsg NVARCHAR(4000),
        @ErrSeverity INT;


      SELECT 
        @ErrMsg = ERROR_MESSAGE(),
        @ErrSeverity = ERROR_SEVERITY();
    

        RAISERROR(N'Error when insert to San Pham: %s', @ErrMsg,1, @ErrSeverity);
        RETURN;
    END CATCH
END

GO
/*UPDATE SAN PHAM*/
CREATE OR ALTER PROCEDURE PROC_UPDATE_SAN_PHAM (
      @Ma_so_san_pham             MA_TYPE,         -- MUST exist

      @Ten_san_pham               NVARCHAR(50) = NULL,
      @Luu_y                      NVARCHAR(100) = NULL,
      @Gia_tien                   TIEN_TYPE      = NULL,
      @Loai_san_pham              INT            = NULL,
      @Don_vi_tinh                NVARCHAR(10)   = NULL,
      @Quy_cach                   NVARCHAR(50)   = NULL,
      @Mo_ta_ngan                 NVARCHAR(200)  = NULL,
      @Xuat_xu                    NVARCHAR(50)   = NULL,
      @Ma_so_thue_cong_ty         MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu               NVARCHAR(200)  = NULL,
      @Ma_so_thuong_hieu          MA_TYPE        = NULL,
      @Ten_danh_muc               NVARCHAR(30)   = NULL,
      @Cong_dung                  NVARCHAR(200)  = NULL,
      @Cach_dung                  NVARCHAR(200)  = NULL,
      @Bao_quan                   NVARCHAR(200)  = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE        = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -------------------------------------------------------------
        -- 0. CHECK record existence
        -------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham
        )
        BEGIN
            RAISERROR(N'Ma_so_san_pham %s does not exist for update.', 
                      16, 1, @Ma_so_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 1. Validate unique Ten_san_pham (only if updating)
        -------------------------------------------------------------
        IF @Ten_san_pham IS NOT NULL AND
           EXISTS (
               SELECT 1 
               FROM SAN_PHAM 
               WHERE Ten_san_pham = @Ten_san_pham
                 AND Ma_so_san_pham <> @Ma_so_san_pham
           )
        BEGIN
            RAISERROR(N'Ten_san_pham %s already exists.', 16, 1, @Ten_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 2. Validate Gia_tien >= 0 (only if updating)
        -------------------------------------------------------------
        IF @Gia_tien IS NOT NULL AND @Gia_tien < 0
        BEGIN
        
            DECLARE @Gia_tien_str NVARCHAR(20) = CONVERT(NVARCHAR(20),@Gia_tien);
        
            RAISERROR(N'Gia_tien %s must be >= 0.', 
                      16, 1, @Gia_tien_str);
            RETURN;
        END

        -------------------------------------------------------------
        -- 3. Validate enum Loai_san_pham (only if updating)
        -------------------------------------------------------------
        IF @Loai_san_pham IS NOT NULL AND 
           @Loai_san_pham NOT IN (1,2,3,4,5)
        BEGIN
            RAISERROR(N'Loai_san_pham %d is invalid. Must be in (1 - THIET_BI_Y_TE, 2 - THUC_PHAM_CHUC_NANG ,3 - DUOC_MY_PHAM, 4 - THUOC , 5 - CHAM_SOC_CA_NHAN).', 
                      16, 1, @Loai_san_pham);
            RETURN;
        END

        -------------------------------------------------------------
        -- 4. Validate FK: Company tax ID exists
        -------------------------------------------------------------
        IF @Ma_so_thue_cong_ty IS NOT NULL AND
           NOT EXISTS (
               SELECT 1 FROM CONG_TY_SAN_XUAT 
               WHERE Ma_so_thue = @Ma_so_thue_cong_ty
           )
        BEGIN
            RAISERROR(N'Ma_so_thue_cong_ty %s does not exist in CONG_TY_SAN_XUAT.', 
                      16, 1, @Ma_so_thue_cong_ty);
            RETURN;
        END

        -------------------------------------------------------------
        -- 5. Validate FK: Brand exists
        -------------------------------------------------------------
        IF @Ma_so_thuong_hieu IS NOT NULL AND
           NOT EXISTS (
               SELECT 1 FROM THUONG_HIEU 
               WHERE Ma_so = @Ma_so_thuong_hieu
           )
        BEGIN
            RAISERROR(N'Ma_so_thuong_hieu %s does not exist in THUONG_HIEU.', 
                      16, 1, @Ma_so_thuong_hieu);
            RETURN;
        END

        -------------------------------------------------------------
        -- 6. Validate FK: Category exists
        -------------------------------------------------------------
        IF @Ten_danh_muc IS NOT NULL AND
           NOT EXISTS (
               SELECT 1 FROM DANH_MUC 
               WHERE Ten = @Ten_danh_muc
           )
        BEGIN
            RAISERROR(N'Ten_danh_muc %s does not exist in DANH_MUC.', 
                      16, 1, @Ten_danh_muc);
            RETURN;
        END

        -------------------------------------------------------------
        -- 7. Validate FK: Specialist employee exists
        -------------------------------------------------------------
        IF @Ma_so_nhan_vien_kiem_duyet IS NOT NULL AND
           NOT EXISTS (
               SELECT 1 FROM NHAN_VIEN_CHUYEN_MON
               WHERE Ma_so_nhan_vien = @Ma_so_nhan_vien_kiem_duyet
           )
        BEGIN
            RAISERROR(N'Ma_so_nhan_vien_kiem_duyet %s does not exist in NHAN_VIEN_CHUYEN_MON.', 
                      16, 1, @Ma_so_nhan_vien_kiem_duyet);
            RETURN;
        END

        -------------------------------------------------------------
        -- 8. Perform UPDATE (only update fields that are NOT NULL)
        -------------------------------------------------------------
        UPDATE SAN_PHAM
        SET
            Ten_san_pham               = COALESCE(@Ten_san_pham, Ten_san_pham),
            Luu_y                      = COALESCE(@Luu_y, Luu_y),
            Gia_tien                   = COALESCE(@Gia_tien, Gia_tien),
            Loai_san_pham              = COALESCE(@Loai_san_pham, Loai_san_pham),
            Don_vi_tinh                = COALESCE(@Don_vi_tinh, Don_vi_tinh),
            Quy_cach                   = COALESCE(@Quy_cach, Quy_cach),
            Mo_ta_ngan                 = COALESCE(@Mo_ta_ngan, Mo_ta_ngan),
            Xuat_xu                    = COALESCE(@Xuat_xu, Xuat_xu),
            Ma_so_thue_cong_ty         = COALESCE(@Ma_so_thue_cong_ty, Ma_so_thue_cong_ty),
            Tac_dung_phu               = COALESCE(@Tac_dung_phu, Tac_dung_phu),
            Ma_so_thuong_hieu          = COALESCE(@Ma_so_thuong_hieu, Ma_so_thuong_hieu),
            Ten_danh_muc               = COALESCE(@Ten_danh_muc, Ten_danh_muc),
            Cong_dung                  = COALESCE(@Cong_dung, Cong_dung),
            Cach_dung                  = COALESCE(@Cach_dung, Cach_dung),
            Bao_quan                   = COALESCE(@Bao_quan, Bao_quan),
            Ma_so_nhan_vien_kiem_duyet = COALESCE(@Ma_so_nhan_vien_kiem_duyet, Ma_so_nhan_vien_kiem_duyet)
        WHERE Ma_so_san_pham = @Ma_so_san_pham;

    END TRY

    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error when update into San_Pham: %s', 16, 1, @Err);
        RETURN;
    END CATCH
END

GO
/*Soft delete SAN PHAM*/
CREATE OR ALTER PROCEDURE PROC_SOFT_DELETE_SAN_PHAM (
      @Ma_so_san_pham             MA_TYPE
)
AS
BEGIN

    SET NOCOUNT ON;
    
    -------------------------------------------------------------
    -- 0. CHECK record existence
    -------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham
    )
    BEGIN
      RAISERROR(N'Ma_so_san_pham %s does not exist for soft delete.', 
                      16, 1, @Ma_so_san_pham);
      RETURN;
    END
    
    IF EXISTS (
        SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham AND Trang_thai = 'S'
    )
    BEGIN
      RAISERROR(N'Can not soft delete san_pham %s as it is already been shutdown.', 
                      16, 1, @Ma_so_san_pham);
      RETURN;
    END
    
    UPDATE SAN_PHAM
    SET Trang_thai = 'S'
    WHERE Ma_so_san_pham = @Ma_so_san_pham;
END

GO

/*Recover SAN PHAM*/
CREATE OR ALTER PROCEDURE PROC_SOFT_RECOVER_SAN_PHAM (
      @Ma_so_san_pham             MA_TYPE
)
AS
BEGIN

    SET NOCOUNT ON;
    
    -------------------------------------------------------------
    -- 0. CHECK record existence
    -------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham
    )
    BEGIN
      RAISERROR(N'Ma_so_san_pham %s does not exist.', 
                      16, 1, @Ma_so_san_pham);
      RETURN;
    END
    
    IF EXISTS (
        SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham AND Trang_thai = 'O'
    )
    BEGIN
      RAISERROR(N'Can not recover san_pham %s as it is current OnShelf.', 
                      16, 1, @Ma_so_san_pham);
      RETURN;
    END
    
    UPDATE SAN_PHAM
    SET Trang_thai = 'O'
    WHERE Ma_so_san_pham = @Ma_so_san_pham;
END

GO

CREATE OR ALTER PROCEDURE PROC_UPSERT_THUOC (
      @Mode                    VARCHAR(10),   -- 'INSERT' or 'UPDATE'

      /* SAN_PHAM PARAMETERS NEEDED (excluding deducible ones such as Loai_san_pham = 4) */
      @Ma_so_san_pham          MA_TYPE,
      @Ten_san_pham            NVARCHAR(50) = NULL,
      @Luu_y                   NVARCHAR(100) = NULL,
      @Gia_tien                TIEN_TYPE      = NULL,
      @Don_vi_tinh             NVARCHAR(10)   = NULL,
      @Quy_cach                NVARCHAR(50)   = NULL,
      @Mo_ta_ngan              NVARCHAR(200)  = NULL,
      @Xuat_xu                 NVARCHAR(50)   = NULL,
      @Ma_so_thue_cong_ty      MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu            NVARCHAR(200) = NULL,
      @Ma_so_thuong_hieu       MA_TYPE        = NULL,
      @Ten_danh_muc            NVARCHAR(30)   = NULL,
      @Cong_dung               NVARCHAR(200)  = NULL,
      @Cach_dung               NVARCHAR(200)  = NULL,
      @Bao_quan                NVARCHAR(200)  = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE     = NULL,

      /* THUOC SUBTYPE PARAMETERS */
      @Loai_thuoc              INT  = 0,
      @Mui_vi_Mui_huong        NVARCHAR(100) = NULL,
      @Chi_dinh                NVARCHAR(100) = NULL,
      @Thanh_phan              NVARCHAR(100) = NULL,
      @Giay_cong_bo_san_pham   NVARCHAR(100) = NULL,
      @Doi_tuong_su_dung       NVARCHAR(100) = NULL,
      @Dang_bao_che            NVARCHAR(100) = NULL,
      @So_dang_ki              SO_DANG_KY_TYPE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    /* ----------------------------------------------
       VALIDATE MODE
    ---------------------------------------------- */
    IF @Mode NOT IN ('INSERT','UPDATE')
    BEGIN
        DECLARE @errMode NVARCHAR(200);
        SET @errMode = FORMATMESSAGE('Invalid mode "%s". Must be INSERT or UPDATE.', @Mode);
        RAISERROR(@errMode, 16, 1);
        RETURN;
    END


    BEGIN TRY

        /* ============================================================
           COMMON VALIDATION FOR THUOC
        ============================================================ */
        IF @Loai_thuoc NOT IN (0,1)
        BEGIN
            DECLARE @errLoai NVARCHAR(200);
            SET @errLoai = FORMATMESSAGE('Invalid Loai_thuoc=%d. Valid values are 0 - Ke don or 1 - Khong Ke Don.', @Loai_thuoc);
            RAISERROR(@errLoai, 16, 1);
            RETURN;
        END


        /* ============================================================
           INSERT MODE
        ============================================================ */
        IF @Mode = 'INSERT'
        BEGIN
            /* Ensure the PK does not exist */
            IF EXISTS (SELECT 1 FROM THUOC WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @errPKI NVARCHAR(200);
                SET @errPKI = FORMATMESSAGE('Cannot INSERT. THUOC with Ma_so_san_pham=%s already exists.', @Ma_so_san_pham);
                RAISERROR(@errPKI, 16, 1);
                RETURN;
            END

            /* First insert SAN_PHAM using your own procedure */
EXEC PROC_INSERT_SAN_PHAM
      @Ma_so_san_pham             = @Ma_so_san_pham
    , @Ten_san_pham               = @Ten_san_pham
    , @Luu_y                      = @Luu_y
    , @Gia_tien                   = @Gia_tien
    , @Loai_san_pham              = 4                   -- DEDUCED
    , @Don_vi_tinh                = @Don_vi_tinh
    , @Quy_cach                   = @Quy_cach
    , @Mo_ta_ngan                 = @Mo_ta_ngan
    , @Xuat_xu                    = @Xuat_xu
    , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
    , @Tac_dung_phu               = @Tac_dung_phu
    , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
    , @Ten_danh_muc               = @Ten_danh_muc
    , @Cong_dung                  = @Cong_dung
    , @Cach_dung                  = @Cach_dung
    , @Bao_quan                   = @Bao_quan
    , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;


            /* Then insert THUOC */
            INSERT INTO THUOC (
                  Ma_so_san_pham
                , Loai_thuoc
                , Mui_vi_Mui_huong
                , Chi_dinh
                , Thanh_phan
                , Giay_cong_bo_san_pham
                , Doi_tuong_su_dung
                , Dang_bao_che
                , So_dang_ki
            )
            VALUES (
                  @Ma_so_san_pham
                , @Loai_thuoc
                , @Mui_vi_Mui_huong
                , @Chi_dinh
                , @Thanh_phan
                , @Giay_cong_bo_san_pham
                , @Doi_tuong_su_dung
                , @Dang_bao_che
                , @So_dang_ki
            );
        END


        /* ============================================================
           UPDATE MODE
        ============================================================ */
        ELSE IF @Mode = 'UPDATE'
        BEGIN
            /* Must exist */
            IF NOT EXISTS (SELECT 1 FROM THUOC WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @errPKU NVARCHAR(200);
                SET @errPKU = FORMATMESSAGE('Cannot UPDATE. THUOC with Ma_so_san_pham=%s does not exist.', @Ma_so_san_pham);
                RAISERROR(@errPKU, 16, 1);
                RETURN;
            END

            /* Update SAN_PHAM first */
EXEC PROC_UPDATE_SAN_PHAM
      @Ma_so_san_pham             = @Ma_so_san_pham
    , @Ten_san_pham               = @Ten_san_pham
    , @Luu_y                      = @Luu_y
    , @Gia_tien                   = @Gia_tien
    , @Loai_san_pham              = NULL                 -- CANNOT change subtype
    , @Don_vi_tinh                = @Don_vi_tinh
    , @Quy_cach                   = @Quy_cach
    , @Mo_ta_ngan                 = @Mo_ta_ngan
    , @Xuat_xu                    = @Xuat_xu
    , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
    , @Tac_dung_phu               = @Tac_dung_phu
    , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
    , @Ten_danh_muc               = @Ten_danh_muc
    , @Cong_dung                  = @Cong_dung
    , @Cach_dung                  = @Cach_dung
    , @Bao_quan                   = @Bao_quan
    , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;


            /* Update THUOC */
            UPDATE THUOC
            SET
                  Loai_thuoc            = @Loai_thuoc
                , Mui_vi_Mui_huong      = @Mui_vi_Mui_huong
                , Chi_dinh              = @Chi_dinh
                , Thanh_phan            = @Thanh_phan
                , Giay_cong_bo_san_pham = @Giay_cong_bo_san_pham
                , Doi_tuong_su_dung     = @Doi_tuong_su_dung
                , Dang_bao_che          = @Dang_bao_che
                , So_dang_ki            = @So_dang_ki
            WHERE Ma_so_san_pham = @Ma_so_san_pham;
        END

    END TRY

    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();

        RAISERROR (@ErrMsg, @ErrSeverity, 1);
        RETURN;
    END CATCH

END
GO

CREATE OR ALTER PROCEDURE PROC_UPSERT_CHAM_SOC_CA_NHAN (
      @Mode                        VARCHAR(10),  -- INSERT or UPDATE

      /* --- SAN_PHAM PARAMETERS (Loai_san_pham is deduced = 5) --- */
      @Ma_so_san_pham              MA_TYPE,
      @Ten_san_pham                NVARCHAR(50) = NULL,
      @Luu_y                       NVARCHAR(100) = NULL,
      @Gia_tien                    TIEN_TYPE      = NULL,
      @Don_vi_tinh                 NVARCHAR(10)   = NULL,
      @Quy_cach                    NVARCHAR(50)   = NULL,
      @Mo_ta_ngan                  NVARCHAR(200)  = NULL,
      @Xuat_xu                     NVARCHAR(50)   = NULL,
      @Ma_so_thue_cong_ty          MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu                NVARCHAR(200)  = NULL,
      @Ma_so_thuong_hieu           MA_TYPE        = NULL,
      @Ten_danh_muc                NVARCHAR(30)   = NULL,
      @Cong_dung                   NVARCHAR(200)  = NULL,
      @Cach_dung                   NVARCHAR(200)  = NULL,
      @Bao_quan                    NVARCHAR(200)  = NULL,
      @Ma_so_nhan_vien_kiem_duyet  MA_TYPE        = NULL,

      /* --- CHAM_SOC_CA_NHAN SUBTYPE FIELDS --- */
      @Loai_da                     NVARCHAR(100) = NULL,
      @Mui_vi_Mui_huong            NVARCHAR(100) = NULL,
      @Chi_dinh                    NVARCHAR(100) = NULL,
      @Doi_tuong_su_dung           NVARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    /* --------------------------------------------------------
       Validate Mode
    -------------------------------------------------------- */
    IF @Mode NOT IN ('INSERT','UPDATE')
    BEGIN
        DECLARE @errMode NVARCHAR(200);
        SET @errMode = FORMATMESSAGE('Invalid mode "%s". Must be INSERT or UPDATE.', @Mode);
        RAISERROR(@errMode, 16, 1);
        RETURN;
    END


    BEGIN TRY

        /* ============================================================
           INSERT MODE
        ============================================================ */
        IF @Mode = 'INSERT'
        BEGIN
            /* PK must NOT exist */
            IF EXISTS (SELECT 1 FROM CHAM_SOC_CA_NHAN WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @errPKI NVARCHAR(200);
                SET @errPKI = FORMATMESSAGE(
                    'Cannot INSERT. CHAM_SOC_CA_NHAN with Ma_so_san_pham=%s already exists.',
                    @Ma_so_san_pham
                );
                RAISERROR(@errPKI, 16, 1);
                RETURN;
            END

            /* Insert SAN_PHAM first */
            EXEC PROC_INSERT_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = 5       -- deduced
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            /* Then insert subtype */
            INSERT INTO CHAM_SOC_CA_NHAN (
                  Ma_so_san_pham
                , Loai_da
                , Mui_vi_Mui_huong
                , Chi_dinh
                , Doi_tuong_su_dung
            )
            VALUES (
                  @Ma_so_san_pham
                , @Loai_da
                , @Mui_vi_Mui_huong
                , @Chi_dinh
                , @Doi_tuong_su_dung
            );
        END


        /* ============================================================
           UPDATE MODE
        ============================================================ */
        ELSE IF @Mode = 'UPDATE'
        BEGIN
            /* PK must EXIST */
            IF NOT EXISTS (SELECT 1 FROM CHAM_SOC_CA_NHAN WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @errPKU NVARCHAR(200);
                SET @errPKU = FORMATMESSAGE(
                    'Cannot UPDATE. CHAM_SOC_CA_NHAN with Ma_so_san_pham=%s does not exist.',
                    @Ma_so_san_pham
                );
                RAISERROR(@errPKU, 16, 1);
                RETURN;
            END

            /* Update SAN_PHAM */
            EXEC PROC_UPDATE_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = NULL   -- cannot change subtype!
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            /* Update subtype */
            UPDATE CHAM_SOC_CA_NHAN
            SET
                  Loai_da           = @Loai_da
                , Mui_vi_Mui_huong  = @Mui_vi_Mui_huong
                , Chi_dinh          = @Chi_dinh
                , Doi_tuong_su_dung = @Doi_tuong_su_dung
            WHERE Ma_so_san_pham = @Ma_so_san_pham;
        END

    END TRY

    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();

        RAISERROR (@ErrMsg, @ErrSeverity, 1);
        RETURN;
    END CATCH
    
END;
GO

CREATE OR ALTER PROCEDURE PROC_UPSERT_TBYT
(
      @Mode                 NVARCHAR(10),   -- 'INSERT' or 'UPDATE'
      @Ma_so_san_pham       MA_TYPE,
      @Ten_san_pham         NVARCHAR(50) = NULL,
      @Luu_y                NVARCHAR(100) = NULL,
      @Gia_tien             TIEN_TYPE = NULL,
      @Don_vi_tinh          NVARCHAR(10) = NULL,
      @Quy_cach             NVARCHAR(50) = NULL,
      @Mo_ta_ngan           NVARCHAR(200) = NULL,
      @Xuat_xu              NVARCHAR(50) = NULL,
      @Ma_so_thue_cong_ty   MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu         NVARCHAR(200) = NULL,
      @Ma_so_thuong_hieu    MA_TYPE = NULL,
      @Ten_danh_muc         NVARCHAR(30) = NULL,
      @Cong_dung            NVARCHAR(200) = NULL,
      @Cach_dung            NVARCHAR(200) = NULL,
      @Bao_quan             NVARCHAR(200) = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------
    -- Normalize mode
    -------------------------------------------------------------------
    SET @Mode = UPPER(LTRIM(RTRIM(@Mode)));

    -------------------------------------------------------------------
    -- Validate Mode
    -------------------------------------------------------------------
    IF @Mode NOT IN ('INSERT', 'UPDATE')
    BEGIN
        DECLARE @err1 NVARCHAR(200);
        SET @err1 = FORMATMESSAGE('Invalid mode provided: "%s". Mode must be INSERT or UPDATE.', @Mode);
        RAISERROR(@err1, 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -------------------------------------------------------------------
        -- INSERT MODE
        -------------------------------------------------------------------
        IF @Mode = 'INSERT'
        BEGIN
            -- Check if already exists
            IF EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @err2 NVARCHAR(200);
                SET @err2 = FORMATMESSAGE('Cannot INSERT. Product with ID "%s" already exists.', @Ma_so_san_pham);
                RAISERROR(@err2, 16, 1);
                RETURN;
            END;

            -------------------------------------------------------------------
            -- Insert SAN_PHAM first (Loai_san_pham is deduced = 1)
            -------------------------------------------------------------------
            EXEC PROC_INSERT_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = 1
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            -------------------------------------------------------------------
            -- Insert into THIET_BI_Y_TE
            -------------------------------------------------------------------
            INSERT INTO THIET_BI_Y_TE (Ma_so_san_pham)
            VALUES (@Ma_so_san_pham);
        END;

        -------------------------------------------------------------------
        -- UPDATE MODE
        -------------------------------------------------------------------
        IF @Mode = 'UPDATE'
        BEGIN
            -- Validate exists
            IF NOT EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @err3 NVARCHAR(200);
                SET @err3 = FORMATMESSAGE('Cannot UPDATE. Product with ID "%s" does not exist.', @Ma_so_san_pham);
                RAISERROR(@err3, 16, 1);
                RETURN;
            END;

            -------------------------------------------------------------------
            -- Update SAN_PHAM first (Loai_san_pham is not changed)
            -------------------------------------------------------------------
            EXEC PROC_UPDATE_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = NULL   -- not allowed to change
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            -- THIET_BI_Y_TE has no other fields to update
        END;
    END TRY

    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();

        RAISERROR (@ErrMsg, @ErrSeverity, 1);
        RETURN;
    END CATCH
    
END;
GO

CREATE OR ALTER PROCEDURE PROC_UPSERT_TPCN
(
      @Mode                 NVARCHAR(10),   -- 'INSERT' or 'UPDATE'

      -- SAN_PHAM fields
      @Ma_so_san_pham       MA_TYPE,
      @Ten_san_pham         NVARCHAR(50) = NULL,
      @Luu_y                NVARCHAR(100) = NULL,
      @Gia_tien             TIEN_TYPE = NULL,
      @Don_vi_tinh          NVARCHAR(10) = NULL,
      @Quy_cach             NVARCHAR(50) = NULL,
      @Mo_ta_ngan           NVARCHAR(200) = NULL,
      @Xuat_xu              NVARCHAR(50) = NULL,
      @Ma_so_thue_cong_ty   MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu         NVARCHAR(200) = NULL,
      @Ma_so_thuong_hieu    MA_TYPE = NULL,
      @Ten_danh_muc         NVARCHAR(30) = NULL,
      @Cong_dung            NVARCHAR(200) = NULL,
      @Cach_dung            NVARCHAR(200) = NULL,
      @Bao_quan             NVARCHAR(200) = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE = NULL,

      -- Subtype THUC_PHAM_CHUC_NANG fields
      @Chi_dinh                 NVARCHAR(100) = NULL,
      @Thanh_phan               NVARCHAR(100) = NULL,
      @Giay_cong_bo_san_pham    NVARCHAR(100) = NULL,
      @Mui_vi_huong_vi          NVARCHAR(50)  = NULL,
      @Dang_bao_che             NVARCHAR(50)  = NULL,
      @Doi_tuong_su_dung        NVARCHAR(50)  = NULL,
      @So_dang_ki               VARCHAR(50)   = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------
    -- Normalize mode
    --------------------------------------------------------------
    SET @Mode = UPPER(LTRIM(RTRIM(@Mode)));

    --------------------------------------------------------------
    -- Validate mode
    --------------------------------------------------------------
    IF @Mode NOT IN ('INSERT', 'UPDATE')
    BEGIN
        DECLARE @err0 NVARCHAR(200);
        SET @err0 = FORMATMESSAGE('Invalid mode "%s". Must be INSERT or UPDATE.', @Mode);
        RAISERROR(@err0, 16, 1);
        RETURN;
    END;

    BEGIN TRY

        --------------------------------------------------------------
        -- INSERT MODE
        --------------------------------------------------------------
        IF @Mode = 'INSERT'
        BEGIN
            IF EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @err1 NVARCHAR(200);
                SET @err1 = FORMATMESSAGE('Cannot INSERT. Product with ID "%s" already exists.', @Ma_so_san_pham);
                RAISERROR(@err1, 16, 1);
                RETURN;
            END;

            ----------------------------------------------------------
            -- Insert SAN_PHAM (Loai_san_pham = 2 derived)
            ----------------------------------------------------------
            EXEC PROC_INSERT_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = 2        -- Deduce subtype
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            ----------------------------------------------------------
            -- Insert subtype record
            ----------------------------------------------------------
            INSERT INTO THUC_PHAM_CHUC_NANG
            (
                Ma_so_san_pham,
                Chi_dinh,
                Thanh_phan,
                Giay_cong_bo_san_pham,
                Mui_vi_huong_vi,
                Dang_bao_che,
                Doi_tuong_su_dung,
                So_dang_ki
            )
            VALUES
            (
                @Ma_so_san_pham,
                @Chi_dinh,
                @Thanh_phan,
                @Giay_cong_bo_san_pham,
                @Mui_vi_huong_vi,
                @Dang_bao_che,
                @Doi_tuong_su_dung,
                @So_dang_ki
            );
        END;

        --------------------------------------------------------------
        -- UPDATE MODE
        --------------------------------------------------------------
        IF @Mode = 'UPDATE'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SAN_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                DECLARE @err2 NVARCHAR(200);
                SET @err2 = FORMATMESSAGE('Cannot UPDATE. Product ID "%s" does not exist.', @Ma_so_san_pham);
                RAISERROR(@err2, 16, 1);
                RETURN;
            END;

            ----------------------------------------------------------
            -- Update SAN_PHAM
            ----------------------------------------------------------
            EXEC PROC_UPDATE_SAN_PHAM
                  @Ma_so_san_pham             = @Ma_so_san_pham
                , @Ten_san_pham               = @Ten_san_pham
                , @Luu_y                      = @Luu_y
                , @Gia_tien                   = @Gia_tien
                , @Loai_san_pham              = NULL   -- Not allowed to change
                , @Don_vi_tinh                = @Don_vi_tinh
                , @Quy_cach                   = @Quy_cach
                , @Mo_ta_ngan                 = @Mo_ta_ngan
                , @Xuat_xu                    = @Xuat_xu
                , @Ma_so_thue_cong_ty         = @Ma_so_thue_cong_ty
                , @Tac_dung_phu               = @Tac_dung_phu
                , @Ma_so_thuong_hieu          = @Ma_so_thuong_hieu
                , @Ten_danh_muc               = @Ten_danh_muc
                , @Cong_dung                  = @Cong_dung
                , @Cach_dung                  = @Cach_dung
                , @Bao_quan                   = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            ----------------------------------------------------------
            -- Update subtype fields
            ----------------------------------------------------------
            UPDATE THUC_PHAM_CHUC_NANG
            SET 
                Chi_dinh              = @Chi_dinh,
                Thanh_phan            = @Thanh_phan,
                Giay_cong_bo_san_pham = @Giay_cong_bo_san_pham,
                Mui_vi_huong_vi       = @Mui_vi_huong_vi,
                Dang_bao_che          = @Dang_bao_che,
                Doi_tuong_su_dung     = @Doi_tuong_su_dung,
                So_dang_ki            = @So_dang_ki
            WHERE Ma_so_san_pham = @Ma_so_san_pham;
        END;

    END TRY

    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();

        RAISERROR (@ErrMsg, @ErrSeverity, 1);
        RETURN;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE PROC_UPSERT_DUOC_MY_PHAM
(
      @Mode                        NVARCHAR(10),  -- 'INSERT' or 'UPDATE'

      -- SAN_PHAM PARAMETERS (EXCEPT Loai_san_pham, deduced as 3)
      @Ma_so_san_pham             MA_TYPE,
      @Ten_san_pham               NVARCHAR(50) = NULL,
      @Luu_y                      NVARCHAR(100) = NULL,
      @Gia_tien                   TIEN_TYPE      = NULL,
      @Don_vi_tinh                NVARCHAR(10)   = NULL,
      @Quy_cach                   NVARCHAR(50)   = NULL,
      @Mo_ta_ngan                 NVARCHAR(200)  = NULL,
      @Xuat_xu                    NVARCHAR(50)   = NULL,
      @Ma_so_thue_cong_ty         MA_SO_THUE_TYPE = NULL,
      @Tac_dung_phu               NVARCHAR(200)  = NULL,
      @Ma_so_thuong_hieu          MA_TYPE        = NULL,
      @Ten_danh_muc               NVARCHAR(30)   = NULL,
      @Cong_dung                  NVARCHAR(200)  = NULL,
      @Cach_dung                  NVARCHAR(200)  = NULL,
      @Bao_quan                   NVARCHAR(200)  = NULL,
      @Ma_so_nhan_vien_kiem_duyet MA_TYPE        = NULL,

      -- DUOC_MY_PHAM PARAMETERS
      @Loai_da                    NVARCHAR(100) = NULL,
      @Chi_dinh                   NVARCHAR(100) = NULL,
      @Thanh_phan                 NVARCHAR(100) = NULL,
      @Giay_cong_bo_san_pham      NVARCHAR(100) = NULL,
      @Doi_tuong_su_dung          NVARCHAR(50)  = NULL,
      @So_dang_ki                 INT           = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Loai_san_pham INT = 3;   -- DEDUCED: Duoc My Pham = 3

        --------------------------------------------------------
        -- VALIDATE MODE
        --------------------------------------------------------
        IF @Mode NOT IN ('INSERT','UPDATE')
        BEGIN
            RAISERROR('Invalid @Mode supplied: %s. Must be INSERT or UPDATE.', 16, 1, @Mode);
            RETURN;
        END;

        --------------------------------------------------------
        -- VALIDATE SUBTYPE CONSTRAINTS
        --------------------------------------------------------
        IF @So_dang_ki IS NOT NULL AND @So_dang_ki < 0
        BEGIN
            RAISERROR('Invalid So_dang_ki %d. Must be >= 0.', 16, 1, @So_dang_ki);
            RETURN;
        END;

        --------------------------------------------------------
        -- INSERT MODE
        --------------------------------------------------------
        IF @Mode = 'INSERT'
        BEGIN
            -- MUST NOT ALREADY EXIST
            IF EXISTS (SELECT 1 FROM DUOC_MY_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                RAISERROR('Cannot INSERT because Ma_so_san_pham %s already exists in DUOC_MY_PHAM.', 16, 1, @Ma_so_san_pham);
                RETURN;
            END;

            --------------------------------------------------------
            -- First insert SAN_PHAM (parent)
            --------------------------------------------------------
            EXEC PROC_INSERT_SAN_PHAM
                  @Ma_so_san_pham       = @Ma_so_san_pham
                , @Ten_san_pham         = @Ten_san_pham
                , @Luu_y                = @Luu_y
                , @Gia_tien             = @Gia_tien
                , @Loai_san_pham        = @Loai_san_pham   -- deduced = 3
                , @Don_vi_tinh          = @Don_vi_tinh
                , @Quy_cach             = @Quy_cach
                , @Mo_ta_ngan           = @Mo_ta_ngan
                , @Xuat_xu              = @Xuat_xu
                , @Ma_so_thue_cong_ty   = @Ma_so_thue_cong_ty
                , @Tac_dung_phu         = @Tac_dung_phu
                , @Ma_so_thuong_hieu    = @Ma_so_thuong_hieu
                , @Ten_danh_muc         = @Ten_danh_muc
                , @Cong_dung            = @Cong_dung
                , @Cach_dung            = @Cach_dung
                , @Bao_quan             = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            --------------------------------------------------------
            -- Insert DUOC_MY_PHAM (child)
            --------------------------------------------------------
            INSERT INTO DUOC_MY_PHAM (
                  Ma_so_san_pham
                , Loai_da
                , Chi_dinh
                , Thanh_phan
                , Giay_cong_bo_san_pham
                , Doi_tuong_su_dung
                , So_dang_ki
            )
            VALUES (
                  @Ma_so_san_pham
                , @Loai_da
                , @Chi_dinh
                , @Thanh_phan
                , @Giay_cong_bo_san_pham
                , @Doi_tuong_su_dung
                , @So_dang_ki
            );

            RETURN;
        END;

        --------------------------------------------------------
        -- UPDATE MODE
        --------------------------------------------------------
        IF @Mode = 'UPDATE'
        BEGIN
            -- MUST ALREADY EXIST
            IF NOT EXISTS (SELECT 1 FROM DUOC_MY_PHAM WHERE Ma_so_san_pham = @Ma_so_san_pham)
            BEGIN
                RAISERROR('Cannot UPDATE because Ma_so_san_pham %s does not exist in DUOC_MY_PHAM.', 16, 1, @Ma_so_san_pham);
                RETURN;
            END;

            --------------------------------------------------------
            -- Update SAN_PHAM (parent)
            --------------------------------------------------------
            EXEC PROC_UPDATE_SAN_PHAM
                  @Ma_so_san_pham       = @Ma_so_san_pham
                , @Ten_san_pham         = @Ten_san_pham
                , @Luu_y                = @Luu_y
                , @Gia_tien             = @Gia_tien
                , @Loai_san_pham        = @Loai_san_pham   -- deduced = 3; updating allowed
                , @Don_vi_tinh          = @Don_vi_tinh
                , @Quy_cach             = @Quy_cach
                , @Mo_ta_ngan           = @Mo_ta_ngan
                , @Xuat_xu              = @Xuat_xu
                , @Ma_so_thue_cong_ty   = @Ma_so_thue_cong_ty
                , @Tac_dung_phu         = @Tac_dung_phu
                , @Ma_so_thuong_hieu    = @Ma_so_thuong_hieu
                , @Ten_danh_muc         = @Ten_danh_muc
                , @Cong_dung            = @Cong_dung
                , @Cach_dung            = @Cach_dung
                , @Bao_quan             = @Bao_quan
                , @Ma_so_nhan_vien_kiem_duyet = @Ma_so_nhan_vien_kiem_duyet;

            --------------------------------------------------------
            -- Update DUOC_MY_PHAM (child)
            --------------------------------------------------------
            UPDATE DUOC_MY_PHAM
            SET
                  Loai_da               = @Loai_da
                , Chi_dinh              = @Chi_dinh
                , Thanh_phan            = @Thanh_phan
                , Giay_cong_bo_san_pham = @Giay_cong_bo_san_pham
                , Doi_tuong_su_dung     = @Doi_tuong_su_dung
                , So_dang_ki            = @So_dang_ki
            WHERE Ma_so_san_pham = @Ma_so_san_pham;

            RETURN;
        END;

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrState INT = ERROR_STATE();
        RAISERROR('ERROR in PROC_UPSERT_DUOC_MY_PHAM: %s', 16, 1, @ErrMsg);
    END CATCH;
END;
GO


PRINT '>>> END INSERT UPDATE DELETE PROCEDURE >>>'

GO

PRINT '>>> BEGIN DML TRIGGER >>>'

GO

/*Age of the employee must be >= 18*/
CREATE OR ALTER TRIGGER CHECK_EMPLOYEE_AGE_ND
ON NGUOI_DUNG
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @err_id MA_TYPE;


    -- Find any employee being updated whose age < 18
    SELECT TOP 1 @err_id = ind.Ma_so
    FROM INSERTED IND
    JOIN NHAN_VIEN NV ON IND.Ma_so = NV.Ma_so_nhan_vien
    WHERE IND.Ngay_sinh IS NOT NULL
      AND DATEADD(YEAR, 18, IND.Ngay_sinh) > GETDATE();


    IF (@err_id IS NOT NULL)
    BEGIN
        ROLLBACK TRANSACTION;


        RAISERROR (
            'Cannot change the age of NHAN_VIEN %s because there age must be >= 18 years old',
            16,
            1,
            @err_id
        );
    END
END;

GO

/*Age of the employee must be >= 18*/
CREATE OR ALTER TRIGGER CHECK_EMPLOYEE_AGE_NV
ON NHAN_VIEN
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @err_id MA_TYPE;


    -- Find any employee being updated whose age < 18
    SELECT TOP 1 @err_id = INV.Ma_so_nhan_vien
    FROM INSERTED INV
    JOIN NGUOI_DUNG ND ON ND.Ma_so = INV.Ma_so_nhan_vien
    WHERE ND.Ngay_sinh IS NOT NULL
      AND DATEADD(YEAR, 18, ND.Ngay_sinh) > GETDATE();


    IF (@err_id IS NOT NULL)
    BEGIN
        ROLLBACK TRANSACTION;


        RAISERROR (
            'NGUOI DUNG %s can not be NHAN_VIEN as their age must be >= 18 years old.',
            16,
            1,
            @err_id
        );
    END
END;


GO

/*
SELECT *
FROM NHAN_VIEN

SELECT *
FROM NGUOI_DUNG

GO

PRINT '===== BEGIN CHECK AGE TESTCASES ====='
PRINT 'TESTNO.1'

-- TEST 1: INSERT employee **under 18** → should FAIL
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NDTEST001', N'Test Underage', '0900000000', 'M', '2008-05-05', 'abc');

INSERT INTO NHAN_VIEN (Ma_so_nhan_vien, So_dinh_danh, Ngay_bat_dau_lam_viec, Luong, Anh_nhan_vien, Email, Thuong_them, Nganh_nghe, Ngay_lam_viec)
VALUES ('NDTEST001', '999999999999', '2023-01-01', 9000000, 't.jpg', 't@example.com', 1000000, 'DUOC_SI', 5);
PRINT 'END TESTNO.1'
GO

PRINT 'TESTNO.2'
-- TEST 2: INSERT employee **exactly 18 years old** → should PASS
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NDTEST002', N'Test Exact 18', '0900000001', 'F', DATEADD(YEAR, -18, GETDATE()), 'abc');

INSERT INTO NHAN_VIEN (Ma_so_nhan_vien, So_dinh_danh, Ngay_bat_dau_lam_viec, Luong, Anh_nhan_vien, Email, Thuong_them, Nganh_nghe, Ngay_lam_viec)
VALUES ('NDTEST002', '999999999998', GETDATE(), 9500000, 't2.jpg', 't2@example.com', 1500000, 'NHAN_VIEN_CHUYEN_MON', 4);
PRINT 'END TESTNO.2'
GO


PRINT 'TESTNO.3'
-- TEST 3: INSERT employee **over 18** → should PASS
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NDTEST003', N'Test Over 18', '0900000002', 'M', '1990-01-01', 'abc');

INSERT INTO NHAN_VIEN (Ma_so_nhan_vien, So_dinh_danh, Ngay_bat_dau_lam_viec, Luong, Anh_nhan_vien, Email, Thuong_them, Nganh_nghe, Ngay_lam_viec)
VALUES ('NDTEST003', '999999999997', '2022-01-01', 10000000, 't3.jpg', 't3@example.com', 1200000, 'NHAN_VIEN_MARKETING', 6);
PRINT 'END TESTNO.3'
GO


PRINT 'TESTNO.4'
-- TEST 4: UPDATE an existing employee to make them **under 18** → should FAIL
-- Example: ND0000035 (born 1995-12-31) → temporarily change birthdate to 2010
UPDATE NGUOI_DUNG SET Ngay_sinh = '2008-01-01'
WHERE Ma_so = 'ND0000025';
PRINT 'END TESTNO.4'
GO


PRINT 'TESTNO.5'
-- TEST 5: UPDATE an employee (valid birthdate) → should PASS
UPDATE NGUOI_DUNG SET Ho_va_ten = N'Tên Mới Hợp Lệ'
WHERE Ma_so = 'ND0000006';
PRINT 'END TESTNO.5'
GO


PRINT 'TESTNO.6'
-- TEST 6: INSERT NHAN_VIEN without matching NGUOI_DUNG → should FAIL (FK constraint)
INSERT INTO NHAN_VIEN (Ma_so_nhan_vien, So_dinh_danh, Ngay_bat_dau_lam_viec, Luong, Anh_nhan_vien, Email, Thuong_them, Nganh_nghe, Ngay_lam_viec)
VALUES ('NDNOTEXIS', '888888888888', '2021-01-01', 10000000, 'na.jpg', 'na@example.com', 1200000, 'NHAN_VIEN_CHUYEN_MON', 3);
PRINT 'END TESTNO.6'
GO


PRINT 'TESTNO.7'
-- TEST 7: INSERT NGUOI_DUNG age < 18 but DO NOT insert NHAN_VIEN → should PASS (trigger should not fire)
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NDUNDER18', N'Under 18 Only', '0900000003', 'F', '2008-02-02', 'abc');
PRINT 'END TESTNO.7'
GO


PRINT 'TESTNO.8'
-- TEST 8: Revert the invalid age in TEST 4 so data stays clean
UPDATE NGUOI_DUNG SET Ngay_sinh = '1995-12-31'
WHERE Ma_so = 'ND0000025';
PRINT 'END TESTNO.8'
GO

PRINT '===== END CHECK AGE TESTCASES ====='

*/
GO

CREATE OR ALTER TRIGGER CHECK_BOUGHT_AGE
ON GOM_SP_DH
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @err_id MA_TYPE;
    
    SELECT TOP 1 @err_id = DH.Ma_don_hang
    FROM DON_HANG DH, SAN_PHAM SP, INSERTED ISPDH, NGUOI_DUNG ND
    WHERE DH.Ma_don_hang = ISPDH.Ma_don_hang AND ISPDH.Ma_san_pham = SP.Ma_so_san_pham
        AND DH.Ma_so_nguoi_mua_hang = ND.Ma_so
        AND ( SP.Loai_san_pham = 2 OR SP.Loai_san_pham = 4 )
        AND DATEADD(YEAR, 18, ND.Ngay_sinh) > GETDATE();


    IF (@err_id IS NOT NULL)
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Don hang %s is not allowed as the customer whoes age < 18 is buying Thuoc and Thuc Pham Chuc Nang',16,1,@err_id);
    END
END

GO

GO
/*
PRINT '===== BEGIN CHECK BOUGHT AGE TESTCASES ====='
*/
/*
SELECT *
FROM SAN_PHAM;

SELECT *
FROM GOM_SP_DH;

SELECT *
FROM NGUOI_DUNG;

SELECT *
FROM NGUOI_MUA_HANG;

SELECT *
FROM DON_HANG;
*/


GO
/*
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NMHTEST01', N'Valid Buyer > 18', '0900000000', 'M', '1992-05-05', 'abc');

INSERT INTO NGUOI_MUA_HANG (Ma_so_nguoi_mua_hang, Dia_chi_mac_dinh)
VALUES ('NMHTEST01', N'NO WHERE');

EXEC insertOrder 
    @Ma_don_hang = 'DH0000T25',
    @Ma_so_nguoi_mua_hang = 'NMHTEST01',
    @Ho_ten_nguoi_nhan = N'Valid Buyer > 18',
    @So_dien_thoai_nguoi_nhan = '0900000000',   -- contains letters
    @Dia_chi_nhan = N'Test address';
    
GO
    
INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NMHTEST11', N'Valid Buyer > 18', '0900000000', 'M', '2000-05-05', 'abc');

INSERT INTO NGUOI_MUA_HANG (Ma_so_nguoi_mua_hang, Dia_chi_mac_dinh)
VALUES ('NMHTEST11', N'NO WHERE');

EXEC insertOrder 
    @Ma_don_hang = 'DH0000T24',
    @Ma_so_nguoi_mua_hang = 'NMHTEST01',
    @Ho_ten_nguoi_nhan = N'Valid Buyer > 18',
    @So_dien_thoai_nguoi_nhan = '0900000000',   -- contains letters
    @Dia_chi_nhan = N'Test address';
  

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES 
('SP0000009', 'DH0000T24',10),
('SP0000014', 'DH0000T24',110),
('SP0000023', 'DH0000T24',2500);
    
GO

INSERT INTO NGUOI_DUNG (Ma_so, Ho_va_ten, So_dien_thoai, Gioi_tinh, Ngay_sinh, Hash_key_password)
VALUES ('NMHTEST02', N'Valid Buyer < 18', '0900000001', 'M', '2009-05-05', 'abc');

INSERT INTO NGUOI_MUA_HANG (Ma_so_nguoi_mua_hang, Dia_chi_mac_dinh)
VALUES ('NMHTEST02', N'NON EXSIT');

EXEC insertOrder 
    @Ma_don_hang = 'DH0000T30',
    @Ma_so_nguoi_mua_hang = 'NMHTEST02',
    @Ho_ten_nguoi_nhan = N'Valid Buyer < 18',
    @So_dien_thoai_nguoi_nhan = '0900000001',   -- contains letters
    @Dia_chi_nhan = N'Test address';
    
GO
    
PRINT 'TESTNO.1' -- NHMTEST01 CAN BUY THUOC >18--

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES ('SP0000001', 'DH0000T25',3);

PRINT 'END TESTNO.1'
GO

PRINT 'TESTNO.2' -- NHMTEST01 CAN BUY THUC PHAM CHUC NANG  >18--

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES ('SP0000016', 'DH0000T25',5);

PRINT 'END TESTNO.2'
GO

PRINT 'TESTNO.3' -- NHMTEST02 CAN NOT BUY THUOC < 18--

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES ('SP0000001', 'DH0000T30',3);

PRINT 'END TESTNO.3'
GO

PRINT 'TESTNO.4' -- NHMTEST02 CAN NOT BUY THUC PHAM CHUC NANG < 18 --

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES ('SP0000016', 'DH0000T30',5);

PRINT 'END TESTNO.4'
GO

PRINT 'TESTNO.5' -- NHMTEST02 CAN BUY ANYTHING ELSE < 18 --

INSERT INTO GOM_SP_DH (Ma_san_pham, Ma_don_hang, So_luong)
VALUES 
('SP0000009', 'DH0000T30',10),
('SP0000014', 'DH0000T30',110),
('SP0000023', 'DH0000T30',2500)
;

PRINT 'END TESTNO.5'

GO

PRINT 'TESTNO.6' -- NHMTEST02 CAN NOT CHANGE THIER ORDER TO THUOC/ THUC PHAM CHUC NANG --

UPDATE GOM_SP_DH
SET Ma_san_pham = 'SP0000001', So_luong = 40
WHERE Ma_san_pham = 'SP0000009' AND Ma_don_hang = 'DH0000T30'

PRINT 'END TESTNO.6'

GO

PRINT 'TESTNO.7' -- NHMTEST02 CAN NOT CHANGE THIER ORDER TO THUOC/ THUC PHAM CHUC NANG --

UPDATE GOM_SP_DH
SET Ma_san_pham = 'SP0000016', So_luong = 40
WHERE Ma_san_pham = 'SP0000009' AND Ma_don_hang = 'DH0000T30'

PRINT 'END TESTNO.7'

GO

PRINT 'TESTNO.8' -- NHMTEST11 CAN CHANGE THIER ORDER TO THUOC/ THUC PHAM CHUC NANG --

UPDATE GOM_SP_DH
SET Ma_san_pham = 'SP0000001', So_luong = 40
WHERE Ma_san_pham = 'SP0000009' AND Ma_don_hang = 'DH0000T24'

PRINT 'END TESTNO.8'

GO

PRINT 'TESTNO.9' -- NHMTEST01 CAN CHANGE THIER ORDER TO THUOC/ THUC PHAM CHUC NANG --

UPDATE GOM_SP_DH
SET Ma_san_pham = 'SP0000016', So_luong = 40
WHERE Ma_san_pham = 'SP0000009' AND Ma_don_hang = 'DH0000T24'

PRINT 'END TESTNO.9'


PRINT '===== END CHECK BOUGHT AGE TESTCASES ====='
*/
GO

CREATE OR ALTER TRIGGER CHECK_PGG_VALID
ON PHIEU_GIAM_GIA
FOR UPDATE
AS
BEGIN
    DECLARE @err_id MA_TYPE;

    -- Check against GIAM_GIA_PHAN_TRAM
    SELECT TOP 1 @err_id = IPGG.Ma_phieu
    FROM INSERTED IPGG
    JOIN GIAM_GIA_PHAN_TRAM GGPT ON IPGG.Ma_phieu = GGPT.Ma_phieu
    WHERE IPGG.Gia_don_hang_toi_thieu < GGPT.So_tien_giam_toi_da;

    IF @err_id IS NOT NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Giam Gia Phan Tram: Cannot update. Gia_don_hang_toi_thieu of product %s is less than So_tien_giam_toi_da.', 16, 1, @err_id);
        RETURN;
    END

    -- Check against GIAM_GIA_TIEN
    SELECT TOP 1 @err_id = IPGG.Ma_phieu
    FROM INSERTED IPGG
    JOIN GIAM_GIA_TIEN GGT ON IPGG.Ma_phieu = GGT.Ma_phieu
    WHERE IPGG.Gia_don_hang_toi_thieu < GGT.So_tien_giam;

    IF @err_id IS NOT NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Giam Gia Tien: Cannot update. Gia_don_hang_toi_thieu of product %s is less than So_tien_giam.', 16, 1, @err_id);
        RETURN;
    END
END;

GO
CREATE OR ALTER TRIGGER CHECK_GGPT_PGG
ON GIAM_GIA_PHAN_TRAM
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @err_id MA_TYPE;

    SELECT TOP 1 @err_id = IGGPT.Ma_phieu
    FROM INSERTED IGGPT
    JOIN PHIEU_GIAM_GIA PGG ON IGGPT.Ma_phieu = PGG.Ma_phieu
    WHERE IGGPT.So_tien_giam_toi_da IS NOT NULL
      AND IGGPT.So_tien_giam_toi_da > PGG.Gia_don_hang_toi_thieu;

    IF @err_id IS NOT NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Giam Gia Phan Tram: Cannot insert/update. Gia_don_hang_toi_thieu of product %s is less than So_tien_giam_toi_da.', 16, 1, @err_id);
        RETURN;
    END
END;

GO
CREATE OR ALTER TRIGGER CHECK_GGT_PGG
ON GIAM_GIA_TIEN
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @err_id MA_TYPE;

    SELECT TOP 1 @err_id = IGGT.Ma_phieu
    FROM INSERTED IGGT
    JOIN PHIEU_GIAM_GIA PGG ON IGGT.Ma_phieu = PGG.Ma_phieu
    WHERE IGGT.So_tien_giam IS NOT NULL
      AND IGGT.So_tien_giam > PGG.Gia_don_hang_toi_thieu;

    IF @err_id IS NOT NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Giam Gia Tien: Cannot insert/update. Gia_don_hang_toi_thieu of product %s is less than So_tien_giam.', 16, 1, @err_id);
        RETURN;
    END
END;

GO

/*
SELECT *
FROM PHIEU_GIAM_GIA;

SELECT *
FROM GIAM_GIA_PHAN_TRAM;

SELECT *
FROM GIAM_GIA_TIEN;

GO

PRINT '===== BEGIN PHIEU_GIAM_GIA TESTCASES ====='

PRINT 'TESTNO.1';
INSERT INTO PHIEU_GIAM_GIA (Ma_phieu, Loai_giam_phan_tram_tien, Gia_don_hang_toi_thieu, Cho_don_cho_san_pham)
VALUES ('PGG900001', 'P', 200000, 'D');

INSERT INTO GIAM_GIA_PHAN_TRAM (Ma_phieu, Phan_tram_giam, So_tien_giam_toi_da)
VALUES ('PGG900001', 0.10, 50000); -- 50,000 ≤ 200,000 => VALID
PRINT 'END TESTNO.1';
GO

PRINT 'TESTNO.2';
INSERT INTO PHIEU_GIAM_GIA (Ma_phieu, Loai_giam_phan_tram_tien, Gia_don_hang_toi_thieu, Cho_don_cho_san_pham)
VALUES ('PGG900002', 'P', 100000, 'D');

INSERT INTO GIAM_GIA_PHAN_TRAM (Ma_phieu, Phan_tram_giam, So_tien_giam_toi_da)
VALUES ('PGG900002', 0.20, 150000); -- 150,000 > 100,000 => INVALID

PRINT 'END TESTNO.2';
GO

PRINT 'TESTNO.3';
INSERT INTO PHIEU_GIAM_GIA (Ma_phieu, Loai_giam_phan_tram_tien, Gia_don_hang_toi_thieu, Cho_don_cho_san_pham)
VALUES ('PGG900003', 'T', 300000, 'S');

INSERT INTO GIAM_GIA_TIEN (Ma_phieu, So_tien_giam)
VALUES ('PGG900003', 50000); -- 50,000 ≤ 300,000 => VALID
PRINT 'END TESTNO.3';
GO

PRINT 'TESTNO.4';
INSERT INTO PHIEU_GIAM_GIA (Ma_phieu, Loai_giam_phan_tram_tien, Gia_don_hang_toi_thieu, Cho_don_cho_san_pham)
VALUES ('PGG900004', 'T', 100000, 'D');

INSERT INTO GIAM_GIA_TIEN (Ma_phieu, So_tien_giam)
VALUES ('PGG900004', 200000); -- 200,000 > 100,000 => INVALID
PRINT 'END TESTNO.4';
GO

PRINT 'TESTNO.5';
INSERT INTO PHIEU_GIAM_GIA (Ma_phieu, Loai_giam_phan_tram_tien, Gia_don_hang_toi_thieu, Cho_don_cho_san_pham)
VALUES ('PGG900005', 'P', 100000, 'D');

INSERT INTO GIAM_GIA_TIEN (Ma_phieu, So_tien_giam)
VALUES ('PGG900005', 50000); -- INVALID for P-type voucher
PRINT 'END TESTNO.5';
GO

PRINT 'TESTNO.6';
UPDATE PHIEU_GIAM_GIA
SET Gia_don_hang_toi_thieu = 500000
WHERE Ma_phieu = 'PGG000012';  -- existing So_tien_giam = 40,000 => VALID
PRINT 'END TESTNO.6';
GO

PRINT 'TESTNO.7';
UPDATE GIAM_GIA_PHAN_TRAM
SET So_tien_giam_toi_da = 400000  -- Too high
WHERE Ma_phieu = 'PGG000001';     -- min order = 200,000 => INVALID
PRINT 'END TESTNO.7';
GO

PRINT 'TESTNO.8';
UPDATE GIAM_GIA_TIEN
SET So_tien_giam = 999999
WHERE Ma_phieu = 'PGG000011';  -- min = 200,000 => INVALID
PRINT 'END TESTNO.8';
GO

PRINT 'TESTNO.9';
UPDATE PHIEU_GIAM_GIA
SET Gia_don_hang_toi_thieu = 10000
WHERE Ma_phieu = 'PGG000014';  -- existing So_tien_giam = 80,000 => INVALID
PRINT 'END TESTNO.9';
GO

PRINT 'TESTNO.10';
UPDATE GIAM_GIA_PHAN_TRAM
SET So_tien_giam_toi_da = 10000
WHERE Ma_phieu = 'PGG000006';  -- min order = 100,000 => VALID
PRINT 'END TESTNO.10';
GO

PRINT '===== END PHIEU_GIAM_GIA TESTCASES ====='
*/

PRINT '>>> END DML TRIGGER >>>'
GO

PRINT '>>> CALCULATED FUNCTION/TRIGGER >>>'

GO
CREATE OR ALTER FUNCTION COUNT_CAU_HOI_SP (@sp_id MA_TYPE)
RETURNS INT
AS 
BEGIN
    DECLARE @count_sp INT = 0;
    
    SELECT @count_sp = COUNT(*)
    FROM CAU_HOI
    WHERE Ma_so_san_pham = @sp_id;


    RETURN @count_sp
END
GO
/*
SELECT *
FROM CAU_HOI;
*/
GO 
/*
PRINT '===== BEGIN COUNT CAU_HOI_SP TESTCASES ====='

GO

PRINT 'TESTNO.01'
SELECT dbo.COUNT_CAU_HOI_SP('SPTEST0NE') AS So_san_pham; -- COUNT CAU HOI NOT EXTST --
PRINT 'END TESTNO.01'
GO

PRINT 'TESTNO.02'
INSERT INTO SAN_PHAM
(Ma_so_san_pham, Ten_san_pham, Luu_y, Gia_tien, Loai_san_pham, Don_vi_tinh,
 Quy_cach, Mo_ta_ngan, Xuat_xu, Ma_so_thue_cong_ty, Tac_dung_phu,
 Ma_so_thuong_hieu, Ten_danh_muc, Cong_dung, Cach_dung, Bao_quan,
 Ma_so_nhan_vien_kiem_duyet)
VALUES
-- 1–5: THUỐC (Loai = 4)
('SPTEST001', N'Thuốc TESTA1', N'Lưu ý dùng theo toa.', 50000, 4, N'Hộp', N'10 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Điều trị A', N'Uống sau ăn', N'Nơi khô ráo', NULL);

INSERT INTO CAU_HOI (So_thu_tu, Ma_so_san_pham) -- ADD 3 SAN PHAM TO SPTEST001
VALUES
(1,'SPTEST001'),
(2,'SPTEST001'),
(3,'SPTEST001')
;

SELECT dbo.COUNT_CAU_HOI_SP('SPTEST001') AS So_san_pham; -- COUNT CAU HOI NOT EXTST --

PRINT 'END TESTNO.02'
GO

PRINT '===== END COUNT CAU_HOI_SP TESTCASES ====='
*/
GO

CREATE OR ALTER FUNCTION COUNT_DANH_GIA_SP (@sp_id MA_TYPE)
RETURNS INT
AS 
BEGIN
    DECLARE @count_sp INT = 0;
    
    SELECT @count_sp = COUNT(*)
    FROM DANH_GIA
    WHERE Ma_so_san_pham = @sp_id;

    RETURN @count_sp

END

GO
/*
PRINT '===== BEGIN COUNT DANH_GIA_SP TESTCASES ====='

PRINT 'TESTNO.01'
SELECT dbo.COUNT_DANH_GIA_SP('SPTEST0NE') AS So_san_pham; -- COUNT CAU HOI NOT EXTST --
PRINT 'END TESTNO.01'
GO

PRINT 'TESTNO.02'
INSERT INTO SAN_PHAM
(Ma_so_san_pham, Ten_san_pham, Luu_y, Gia_tien, Loai_san_pham, Don_vi_tinh,
 Quy_cach, Mo_ta_ngan, Xuat_xu, Ma_so_thue_cong_ty, Tac_dung_phu,
 Ma_so_thuong_hieu, Ten_danh_muc, Cong_dung, Cach_dung, Bao_quan,
 Ma_so_nhan_vien_kiem_duyet)
VALUES
-- 1–5: THUỐC (Loai = 4)
('SPTEST002', N'Thuốc TESTA2', N'Lưu ý dùng theo toa.', 50000, 4, N'Hộp', N'10 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Điều trị A', N'Uống sau ăn', N'Nơi khô ráo', NULL);

INSERT INTO DANH_GIA (So_thu_tu, Ma_so_san_pham) -- ADD 3 SAN PHAM TO SPTEST001
VALUES
(1,'SPTEST002'),
(2,'SPTEST002'),
(3,'SPTEST002')
;

SELECT dbo.COUNT_DANH_GIA_SP('SPTEST002') AS So_san_pham; -- COUNT CAU HOI NOT EXTST --

PRINT 'END TESTNO.02'
*/
GO

GO

CREATE OR ALTER FUNCTION SAO_DANH_GIA_SP (@sp_id MA_TYPE)
RETURNS DECIMAL(10,2)
AS 
BEGIN
    DECLARE @sao_sp DECIMAL(10,2);
    
    SELECT @sao_sp = AVG(CAST(So_sao AS DECIMAL(10,2)))
    FROM DANH_GIA
    WHERE Ma_so_san_pham = @sp_id;

    RETURN @sao_sp

END
GO

/*
PRINT '===== BEGIN SAO_DANH_GIA TESTCASES ====='

PRINT 'TESTNO.01' 
SELECT dbo.SAO_DANH_GIA_SP('SPTEST0NE') AS Sao_san_pham; -- COUNT CAU HOI NOT EXTST --
PRINT 'END TESTNO.01'
GO

PRINT 'TESTNO.02'
INSERT INTO SAN_PHAM
(Ma_so_san_pham, Ten_san_pham, Luu_y, Gia_tien, Loai_san_pham, Don_vi_tinh,
 Quy_cach, Mo_ta_ngan, Xuat_xu, Ma_so_thue_cong_ty, Tac_dung_phu,
 Ma_so_thuong_hieu, Ten_danh_muc, Cong_dung, Cach_dung, Bao_quan,
 Ma_so_nhan_vien_kiem_duyet)
VALUES
-- 1–5: THUỐC (Loai = 4)
('SPTEST003', N'Thuốc TESTA3', N'Lưu ý dùng theo toa.', 50000, 4, N'Hộp', N'10 viên', N'Thuốc mẫu', N'VN', NULL, NULL, NULL, N'Thuốc', N'Điều trị A', N'Uống sau ăn', N'Nơi khô ráo', NULL);

INSERT INTO DANH_GIA (So_thu_tu, Ma_so_san_pham, So_sao) -- ADD 3 SAN PHAM TO SPTEST003
VALUES
(1,'SPTEST003',4),
(2,'SPTEST003',5),
(3,'SPTEST003',2)
;

SELECT dbo.SAO_DANH_GIA_SP('SPTEST003') AS Sao_danh_gia; -- COUNT CAU HOI NOT EXTST --

PRINT 'END TESTNO.02'
*/

GO

-- DO THONG DUNG: Popularity ---
CREATE OR ALTER FUNCTION CAL_POPULARITY
(@likes INT, @m_date DATE, @n_asns INT, @gamma INT, @beta DECIMAL(5,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @delta_date INT;
    SELECT @delta_date = DATEDIFF(DAY, @m_date, GETDATE());
    RETURN ( @likes + @gamma * @n_asns ) * POWER( 2.718, -@beta * @delta_date )
END;

GO

CREATE OR ALTER FUNCTION GET_POPULARITY (@stt INT, @mssp MA_TYPE)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @likes INT;
    DECLARE @date_ask DATE;
    DECLARE @n_ans INT;
    DECLARE @gamma INT = 3;
    DECLARE @beta DECIMAL(5,2) = 0.01;
    DECLARE @popularity DECIMAL(10,2);


    SELECT 
        @likes = Luot_like,
        @date_ask = Thoi_gian_hoi
    FROM CAU_HOI
    WHERE So_thu_tu = @stt AND Ma_so_san_pham = @mssp;
    
    IF @likes IS NULL
    BEGIN
        SET @likes = 0;
    END
    
    IF @date_ask IS NULL
    BEGIN
        SELECT @date_ask = GETDATE();
    END
    
    SELECT @n_ans = COUNT(*)
    FROM CAU_TRA_LOI
    WHERE So_thu_tu_cau_hoi = @stt AND Ma_so_san_pham = @mssp;
    
    SELECT @popularity = dbo.CAL_POPULARITY(@likes, @date_ask, @n_ans, @gamma, @beta);
    RETURN @popularity;
END

GO

PRINT '===== BEGIN SAO_DANH_GIA TESTCASES ====='

/*
SELECT * FROM CAU_HOI;

SELECT * FROM CAU_TRA_LOI;

SELECT DATEDIFF(DAY, '2025-11-01', GETDATE())

SELECT dbo.GET_POPULARITY(1,'SP0000001') AS Popularity;

*/
PRINT '>>> END CALCULATED FUNCTION/TRIGGER >>>'
GO

/* TRIGGER KIEM TRA KHONG AP DUNG NHIEU MA GIAM GIA CUNG LOAI */
CREATE OR ALTER TRIGGER TR_CHECK_DUPLICATE_DISCOUNT_TYPE
ON AP_MA
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @err_id MA_TYPE;
    
    SELECT TOP 1 @err_id = AM1.Ma_don_hang
    FROM AP_MA AM1 JOIN PHIEU_GIAM_GIA PGG1 ON AM1.Ma_phieu = PGG1.Ma_phieu
    WHERE AM1.Ma_don_hang IN (
        SELECT AM.Ma_don_hang
        FROM AP_MA AM JOIN PHIEU_GIAM_GIA PGG ON AM.Ma_phieu = PGG.Ma_phieu
        WHERE PGG.Loai_ma_giam_gia = PGG1.Loai_ma_giam_gia
        GROUP BY AM.Ma_don_hang
        HAVING COUNT(*) >= 2
      )
    
    IF @err_id IS NOT null
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Don_hang %s can not have both voucher and truc tiep PGG',16,1,@err_id);
    END
    
END
GO
/*
PRINT N'--- KẾT THÚC TẠO TRIGGER ---'

-- Chuẩn bị dữ liệu: Xóa các mã cũ của đơn hàng test DH0000006
DELETE FROM AP_MA WHERE Ma_don_hang = 'DH0000006';
GO

PRINT N'--- 1. TEST CASE 1: ÁP DỤNG MÃ TRỰC TIẾP ĐẦU TIÊN (PGG000002) ---'
PRINT N'DỰ KIẾN: THÀNH CÔNG'
BEGIN TRANSACTION 
BEGIN TRY
    INSERT INTO AP_MA (Ma_don_hang, Ma_phieu)
    VALUES ('DH0000006', 'PGG000002');
    COMMIT TRANSACTION; 
    PRINT N'KẾT QUẢ: THÀNH CÔNG. Mã PGG000002 (Loại T) đã được áp dụng.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 
    PRINT N'KẾT QUẢ: THẤT BẠI (LỖI) - Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- VỊ TRÍ KIỂM TRA TRẠNG THÁI SAU TEST 1 / TRƯỚC TEST 2
PRINT N'------------------------------------------------------------';
PRINT N'--- KIỂM TRA TRẠNG THÁI DỮ LIỆU TRƯỚC KHI CHẠY TEST CASE 2 ---';
SELECT 
    AM.Ma_phieu, 
    PGG.Loai_ma_giam_gia AS Loai_Ma, 
    CASE PGG.Loai_ma_giam_gia WHEN 'T' THEN N'Trực Tiếp' ELSE N'Voucher' END AS Mota
FROM 
    AP_MA AS AM
JOIN 
    PHIEU_GIAM_GIA AS PGG ON AM.Ma_phieu = PGG.Ma_phieu
WHERE 
    Ma_don_hang = 'DH0000006';
PRINT N'------------------------------------------------------------';
GO


PRINT N'--- 2. TEST CASE 2: ÁP DỤNG MÃ CÙNG LOẠI (PGG000005 - Loại T) ---'
PRINT N'DỰ KIẾN: THẤT BẠI - Trigger nên ROLLBACK'
BEGIN TRANSACTION 
BEGIN TRY
    INSERT INTO AP_MA (Ma_don_hang, Ma_phieu)
    VALUES ('DH0000006', 'PGG000005');
    COMMIT TRANSACTION; 
    PRINT N'KẾT QUẢ: THÀNH CÔNG (LỖI) - Đáng lẽ phải thất bại!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
PRINT N'KẾT QUẢ: THẤT BẠI (ĐÚNG) - Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- Dọn dẹp cuối cùng
DELETE FROM AP_MA WHERE Ma_don_hang = 'DH0000006';
GO

GO
PRINT N'--- 3. TEST CASE 3: ÁP DỤNG MÃ KHÁC LOẠI (PGG000001 - Loại V) ---'
PRINT N'DỰ KIẾN: THÀNH CÔNG'

BEGIN TRY
    INSERT INTO AP_MA (Ma_don_hang, Ma_phieu)
    VALUES ('DH0000006', 'PGG000001');
    PRINT N'KẾT QUẢ: THÀNH CÔNG. Mã PGG000001 (Loại V) đã được áp dụng.';
END TRY
BEGIN CATCH
    PRINT N'KẾT QUẢ: THẤT BẠI (LỖI) - Lỗi: ' + ERROR_MESSAGE();
END CATCH

*/
GO

CREATE OR ALTER PROCEDURE SP_DASHBOARD_REVENUE
(
      @Mode INT      -- 1: Branch | 2: Month | 3: Manufacturer | 4: Loai_san_pham
)
AS
BEGIN
      SET NOCOUNT ON;

      /* Base dataset for all statistics */
      WITH BASE AS 
      (
            SELECT 
                  DH.Ma_don_hang,
                  DH.Ma_chi_nhanh_quan_ly,
                  DH.Trang_thai_don_hang,
                  DH.Thoi_gian_ban_giao,
                  SP.Ma_so_san_pham,
                  SP.Loai_san_pham,
                  SP.Ma_so_thue_cong_ty,
                  G.So_luong,
                  SP.Gia_tien,
                  Revenue = G.So_luong * SP.Gia_tien
            FROM DON_HANG DH
            JOIN GOM_SP_DH G   ON G.Ma_don_hang = DH.Ma_don_hang
            JOIN SAN_PHAM SP   ON SP.Ma_so_san_pham = G.Ma_san_pham
            WHERE DH.Trang_thai_don_hang = 3   -- Completed (Delivered)
      ) SELECT * INTO #BASE FROM BASE;
      
      
      /* MODE 1: Revenue by Branch (CHI_NHANH) ----------------------------*/
      IF(@Mode = 1)
      BEGIN
            SELECT 
                  CN.Ma_chi_nhanh,
                  CN.Ten_chi_nhanh,
                  Revenue = SUM(B.Revenue)
            FROM #BASE B
            LEFT JOIN CHI_NHANH CN ON CN.Ma_chi_nhanh = B.Ma_chi_nhanh_quan_ly
            GROUP BY CN.Ma_chi_nhanh, CN.Ten_chi_nhanh
            HAVING SUM(B.Revenue) > 0
            ORDER BY Revenue DESC;
            RETURN;
      END




      /* MODE 2: Revenue by Month ----------------------------------------*/
      IF(@Mode = 2)
      BEGIN
            SELECT
                  Year  = YEAR(B.Thoi_gian_ban_giao),
                  Month = MONTH(B.Thoi_gian_ban_giao),
                  Revenue = SUM(B.Revenue)
            FROM #BASE B
            GROUP BY YEAR(B.Thoi_gian_ban_giao), MONTH(B.Thoi_gian_ban_giao)
            HAVING SUM(B.Revenue) > 0
            ORDER BY Year, Month;
            RETURN;
      END




      /* MODE 3: Revenue by Manufacturer (CONG_TY_SAN_XUAT) ---------------*/
      IF(@Mode = 3)
      BEGIN
            SELECT 
                  CT.Ma_so_thue,
                  CT.Ten_cong_ty,
                  Revenue = SUM(B.Revenue)
            FROM #BASE B
            JOIN CONG_TY_SAN_XUAT CT 
                  ON CT.Ma_so_thue = B.Ma_so_thue_cong_ty
            GROUP BY CT.Ma_so_thue, CT.Ten_cong_ty
            HAVING SUM(B.Revenue) > 0
            ORDER BY Revenue DESC;
            RETURN;
      END




      /* MODE 4: Revenue by Loai_san_pham --------------------------------*/
      IF(@Mode = 4)
      BEGIN
            SELECT 
                  B.Loai_san_pham,
                  Revenue = SUM(B.Revenue)
            FROM #BASE B
            GROUP BY B.Loai_san_pham
            HAVING SUM(B.Revenue) > 0
            ORDER BY Revenue DESC;
            RETURN;
      END


      /* Invalid Mode ------------------------------------------------------*/
      RAISERROR('Invalid @Mode. Accept: 1, 2, 3, 4.', 16, 1);
END
GO

/*
SELECT *
FROM DON_HANG;

SELECT TOP 10 *
FROM SAN_PHAM;

SELECT *
FROM GOM_SP_DH;

SELECT *
FROM CONG_TY_SAN_XUAT;

SELECT *
FROM NGUOI_MUA_HANG;

SELECT *
FROM CHI_NHANH;

*/
GO
/*
-- INSERT SAMPLE DATA --

-- New SAN_PHAM --
EXEC PROC_UPSERT_THUOC 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00001',
    @Ten_san_pham = 'Thuoc Test DB1',
    @Gia_tien = 89000.00,
    @Ma_so_thue_cong_ty = '0123456789';
    
EXEC PROC_UPSERT_THUOC 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00002',
    @Ten_san_pham = 'Thuoc Test DB2',
    @Gia_tien = 25000.00,
    @Ma_so_thue_cong_ty = '0123456789';
    
EXEC PROC_UPSERT_THUOC 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00003',
    @Ten_san_pham = 'Thuoc Test DB3',
    @Gia_tien = 44000.00,
    @Ma_so_thue_cong_ty = '1234567890';    
    
EXEC PROC_UPSERT_THUOC 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00004',
    @Ten_san_pham = 'Thuoc Test DB4',
    @Gia_tien = 20000.00,
    @Ma_so_thue_cong_ty = '1234567890'; 
    
EXEC PROC_UPSERT_THUOC 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00005',
    @Ten_san_pham = 'Thuoc Test DB5',
    @Gia_tien = 45000.00,
    @Ma_so_thue_cong_ty = '2345678901'; 
    
EXEC PROC_UPSERT_CHAM_SOC_CA_NHAN 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00006',
    @Ten_san_pham = 'Thuc pham chuc nang Test DB6',
    @Gia_tien = 11000.00,
    @Ma_so_thue_cong_ty = '0123456789'; 
    
EXEC PROC_UPSERT_CHAM_SOC_CA_NHAN 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00007',
    @Ten_san_pham = 'Thuc pham chuc nang Test DB7',
    @Gia_tien = 4000.00,
    @Ma_so_thue_cong_ty = '1234567890'; 

EXEC PROC_UPSERT_CHAM_SOC_CA_NHAN 
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00008',
    @Ten_san_pham = 'Thuc pham chuc nang Test DB8',
    @Gia_tien = 125000.00,
    @Ma_so_thue_cong_ty = '4567890123'; 

EXEC PROC_UPSERT_TBYT
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00009',
    @Ten_san_pham = 'TBYT Test DB9',
    @Gia_tien = 100000.00,
    @Ma_so_thue_cong_ty = '4567890123'; 
    
EXEC PROC_UPSERT_TBYT
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00010',
    @Ten_san_pham = 'TBYT Test DB10',
    @Gia_tien = 275000.00,
    @Ma_so_thue_cong_ty = '4567890123'; 
    
EXEC PROC_UPSERT_TPCN
    @Mode = 'INSERT',
    @Ma_so_san_pham = 'SPDB00011',
    @Ten_san_pham = 'TPCN Test DB11',
    @Gia_tien = 570000.00,
    @Ma_so_thue_cong_ty = '1234567890'; 
    
    
-- NEW ORDER --

EXEC insertOrder
    @Ma_don_hang = 'DHDB00001',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-10-09 09:30:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 01',
    @So_dien_thoai_nguoi_nhan = '0911151111',
    @Dia_chi_nhan = 'DB TEST',
    @Phi_van_chuyen = '300000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000001';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00002',
    @Ma_so_nguoi_mua_hang = 'ND0000002',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-10-10 10:45:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 02',
    @So_dien_thoai_nguoi_nhan = '0912252222',
    @Dia_chi_nhan = 'DISTRICT 1',
    @Phi_van_chuyen = '250000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000002';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00003',
    @Ma_so_nguoi_mua_hang = 'ND0000003',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-1-11 14:20:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 03',
    @So_dien_thoai_nguoi_nhan = '0933353333',
    @Dia_chi_nhan = 'HCMC TEST',
    @Phi_van_chuyen = '180000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000003';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00004',
    @Ma_so_nguoi_mua_hang = 'ND0000004',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-1-12 08:10:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 04',
    @So_dien_thoai_nguoi_nhan = '0944454444',
    @Dia_chi_nhan = 'HA NOI TEST',
    @Phi_van_chuyen = '310000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000004';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00005',
    @Ma_so_nguoi_mua_hang = 'ND0000005',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-8-13 16:00:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 05',
    @So_dien_thoai_nguoi_nhan = '0955555555',
    @Dia_chi_nhan = 'DB AREA 5',
    @Phi_van_chuyen = '290000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000005';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00006',
    @Ma_so_nguoi_mua_hang = 'ND0000001',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-8-14 11:25:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 06',
    @So_dien_thoai_nguoi_nhan = '0916161616',
    @Dia_chi_nhan = 'TEST LOCATION 6',
    @Phi_van_chuyen = '320000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000006';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00007',
    @Ma_so_nguoi_mua_hang = 'ND0000002',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-10-15 13:45:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 07',
    @So_dien_thoai_nguoi_nhan = '0917171717',
    @Dia_chi_nhan = 'TEST LOCATION 7',
    @Phi_van_chuyen = '210000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000007';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00008',
    @Ma_so_nguoi_mua_hang = 'ND0000003',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-10-16 09:00:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 08',
    @So_dien_thoai_nguoi_nhan = '0918181818',
    @Dia_chi_nhan = 'TEST LOCATION 8',
    @Phi_van_chuyen = '330000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000008';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00009',
    @Ma_so_nguoi_mua_hang = 'ND0000004',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-9-17 15:10:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 09',
    @So_dien_thoai_nguoi_nhan = '0919191919',
    @Dia_chi_nhan = 'TEST LOCATION 9',
    @Phi_van_chuyen = '305000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000009';

EXEC insertOrder
    @Ma_don_hang = 'DHDB00010',
    @Ma_so_nguoi_mua_hang = 'ND0000005',
    @Trang_thai_don_hang = 3,
    @Thoi_gian_dat_hang = '2024-10-09 09:30:00.000',
    @Thoi_gian_ban_giao = '2025-9-18 18:30:00.000',
    @Ho_ten_nguoi_nhan = 'DASHBOARD TEST 10',
    @So_dien_thoai_nguoi_nhan = '0900000000',
    @Dia_chi_nhan = 'FINAL TEST LOCATION',
    @Phi_van_chuyen = '340000.00',
    @Ma_chi_nhanh_quan_ly = 'CN0000010';

INSERT INTO GOM_SP_DH VALUES ('SPDB00001', 'DHDB00001', 5);
INSERT INTO GOM_SP_DH VALUES ('SPDB00002', 'DHDB00001', 3);
INSERT INTO GOM_SP_DH VALUES ('SPDB00003', 'DHDB00001', 7);
INSERT INTO GOM_SP_DH VALUES ('SPDB00004', 'DHDB00001', 2);
INSERT INTO GOM_SP_DH VALUES ('SPDB00005', 'DHDB00001', 9);

INSERT INTO GOM_SP_DH VALUES ('SPDB00006', 'DHDB00002', 4);
INSERT INTO GOM_SP_DH VALUES ('SPDB00007', 'DHDB00002', 11);
INSERT INTO GOM_SP_DH VALUES ('SPDB00008', 'DHDB00002', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00009', 'DHDB00002', 3);
INSERT INTO GOM_SP_DH VALUES ('SPDB00010', 'DHDB00002', 8);

INSERT INTO GOM_SP_DH VALUES ('SPDB00011', 'DHDB00003', 2);
INSERT INTO GOM_SP_DH VALUES ('SPDB00001', 'DHDB00003', 10);
INSERT INTO GOM_SP_DH VALUES ('SPDB00002', 'DHDB00003', 12);
INSERT INTO GOM_SP_DH VALUES ('SPDB00003', 'DHDB00003', 5);
INSERT INTO GOM_SP_DH VALUES ('SPDB00004', 'DHDB00003', 7);

INSERT INTO GOM_SP_DH VALUES ('SPDB00005', 'DHDB00004', 9);
INSERT INTO GOM_SP_DH VALUES ('SPDB00006', 'DHDB00004', 3);
INSERT INTO GOM_SP_DH VALUES ('SPDB00007', 'DHDB00004', 4);
INSERT INTO GOM_SP_DH VALUES ('SPDB00008', 'DHDB00004', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00009', 'DHDB00004', 8);

INSERT INTO GOM_SP_DH VALUES ('SPDB00010', 'DHDB00005', 2);
INSERT INTO GOM_SP_DH VALUES ('SPDB00011', 'DHDB00005', 14);
INSERT INTO GOM_SP_DH VALUES ('SPDB00001', 'DHDB00005', 7);
INSERT INTO GOM_SP_DH VALUES ('SPDB00002', 'DHDB00005', 3);
INSERT INTO GOM_SP_DH VALUES ('SPDB00003', 'DHDB00005', 5);

INSERT INTO GOM_SP_DH VALUES ('SPDB00004', 'DHDB00006', 12);
INSERT INTO GOM_SP_DH VALUES ('SPDB00005', 'DHDB00006', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00006', 'DHDB00006', 8);
INSERT INTO GOM_SP_DH VALUES ('SPDB00007', 'DHDB00006', 9);
INSERT INTO GOM_SP_DH VALUES ('SPDB00008', 'DHDB00006', 3);

INSERT INTO GOM_SP_DH VALUES ('SPDB00009', 'DHDB00007', 4);
INSERT INTO GOM_SP_DH VALUES ('SPDB00010', 'DHDB00007', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00011', 'DHDB00007', 5);
INSERT INTO GOM_SP_DH VALUES ('SPDB00001', 'DHDB00007', 13);
INSERT INTO GOM_SP_DH VALUES ('SPDB00002', 'DHDB00007', 7);

INSERT INTO GOM_SP_DH VALUES ('SPDB00003', 'DHDB00008', 9);
INSERT INTO GOM_SP_DH VALUES ('SPDB00004', 'DHDB00008', 4);
INSERT INTO GOM_SP_DH VALUES ('SPDB00005', 'DHDB00008', 10);
INSERT INTO GOM_SP_DH VALUES ('SPDB00006', 'DHDB00008', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00007', 'DHDB00008', 12);

INSERT INTO GOM_SP_DH VALUES ('SPDB00008', 'DHDB00009', 5);
INSERT INTO GOM_SP_DH VALUES ('SPDB00009', 'DHDB00009', 11);
INSERT INTO GOM_SP_DH VALUES ('SPDB00010', 'DHDB00009', 3);
INSERT INTO GOM_SP_DH VALUES ('SPDB00011', 'DHDB00009', 7);
INSERT INTO GOM_SP_DH VALUES ('SPDB00001', 'DHDB00009', 15);

INSERT INTO GOM_SP_DH VALUES ('SPDB00002', 'DHDB00010', 4);
INSERT INTO GOM_SP_DH VALUES ('SPDB00003', 'DHDB00010', 6);
INSERT INTO GOM_SP_DH VALUES ('SPDB00004', 'DHDB00010', 8);
INSERT INTO GOM_SP_DH VALUES ('SPDB00005', 'DHDB00010', 9);
INSERT INTO GOM_SP_DH VALUES ('SPDB00006', 'DHDB00010', 11);

GO

PRINT '===== DASHBOARD MODE = 1 ====='
    
EXEC SP_DASHBOARD_REVENUE @Mode = 1;

GO
    
PRINT '===== DASHBOARD MODE = 2 ====='

EXEC SP_DASHBOARD_REVENUE @Mode = 2;

GO

PRINT '===== DASHBOARD MODE = 3 ====='

EXEC SP_DASHBOARD_REVENUE @Mode = 3;

GO

PRINT '===== DASHBOARD MODE = 4 ====='
    
EXEC SP_DASHBOARD_REVENUE @Mode = 4;
*/
GO

/*GET DETAIL SAN PHAM*/
CREATE OR ALTER PROCEDURE PROC_GET_SAN_PHAM (
      @Ma_so_san_pham             MA_TYPE
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
      
      DECLARE @prod_type INT;
      
      SELECT @prod_type = Loai_san_pham 
      FROM SAN_PHAM
      WHERE Ma_so_san_pham = @Ma_so_san_pham;
      
      IF @prod_type = 2 -- THUC PHAM CHUC NANG --
      BEGIN
        SELECT *
        FROM SAN_PHAM SP JOIN THUC_PHAM_CHUC_NANG C
          ON SP.Ma_so_san_pham = C.Ma_so_san_pham
        WHERE SP.Ma_so_san_pham = @Ma_so_san_pham;
        
        RETURN;
      END
      
      IF @prod_type = 3 -- DUOC MY PHAM --
      BEGIN
        SELECT *
        FROM SAN_PHAM SP JOIN DUOC_MY_PHAM C 
          ON SP.Ma_so_san_pham = C.Ma_so_san_pham
        WHERE SP.Ma_so_san_pham = @Ma_so_san_pham;
        
        RETURN;
      END
      

      IF @prod_type = 4 -- DUOC MY PHAM --
      BEGIN
        SELECT *
        FROM SAN_PHAM SP JOIN THUOC C 
          ON SP.Ma_so_san_pham = C.Ma_so_san_pham
        WHERE SP.Ma_so_san_pham = @Ma_so_san_pham;
        
        RETURN;
      END
      
      IF @prod_type = 5 -- CHAM SOC CA NHANH --
      BEGIN
        SELECT *
        FROM SAN_PHAM SP JOIN CHAM_SOC_CA_NHAN C 
          ON SP.Ma_so_san_pham = C.Ma_so_san_pham
        WHERE SP.Ma_so_san_pham = @Ma_so_san_pham;
        
        RETURN;
      END
      
      SELECT * 
      FROM SAN_PHAM
      WHERE Ma_so_san_pham = @Ma_so_san_pham;
        
    END TRY

    BEGIN CATCH
    
      DECLARE 
        @ErrMsg NVARCHAR(4000),
        @ErrSeverity INT;


      SELECT 
        @ErrMsg = ERROR_MESSAGE(),
        @ErrSeverity = ERROR_SEVERITY();
    

        RAISERROR(N'Error when trying to get San Pham: %s', @ErrMsg, 1, @ErrSeverity);
        RETURN;
    END CATCH
END
GO

/*
EXEC PROC_GET_SAN_PHAM
  @Ma_so_san_pham = 'SP0000001'

SELECT * FROM SAN_PHAM
*/
GO
/* SEARCH/ FILTER */
CREATE OR ALTER PROCEDURE sp_SearchSanPham
(
    -- Basic search
    @Key_word               NVARCHAR(200) = NULL,   -- search in name, short desc., usage


    -- Criterion for filtering:
    -- Type name from DANH_MUC
    @Ten_danh_muc           NVARCHAR(100) = NULL,   -- recursive category filter


    -- Price range
    @Gia_toi_thieu          TIEN_TYPE  = NULL,
    @Gia_toi_da             TIEN_TYPE  = NULL,


    -- Subtype/ attribute filters from SUBTYPE
    @Doi_tuong_su_dung      NVARCHAR(100) = NULL,
    @Chi_dinh               NVARCHAR(100) = NULL,
    @Loai_thuoc             INT = NULL,  -- 0 => Ke don; 1 => Khong ke don
    @Loai_da                NVARCHAR(100)  = NULL,
    @Mui_huong              NVARCHAR(100) = NULL,


    -- Manufacturer from CONG_TY_SAN_XUAT
    @Nuoc_san_xuat          NVARCHAR(100) = NULL,


    -- Brand from THUONG_HIEU
    @Ten_thuong_hieu        NVARCHAR(100) = NULL,
    @Xuat_xu_thuong_hieu    NVARCHAR(100) = NULL,


    -- Sorting (allowed values below)
    -- LongChau: Sorting = Sorting_criterion + Sorting_direction
    -- Sorting options: price_asc, price_desc, name_asc, name_desc
    @SortBy                 NVARCHAR(20)  = 'price_asc',


    -- Pagination
    @PageNumber             INT = 1,
    @PageSize               INT = 20
)
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
    -- Defensive parameter normalization
    IF @PageNumber IS NULL OR @PageNumber < 1 
        SET @PageNumber = 1;
    IF @PageSize IS NULL OR @PageSize <= 0 
        SET @PageSize = 20;


    -- Normalize search key
    IF @Key_word IS NOT NULL
        SET @Key_word = NULLIF(LTRIM(RTRIM(@Key_word)), N'');


    -- If there's no other purpose that actually needs `Categories`, use table expr appr.
    -- Table expr SQL is inlined with main SELECT => No diff. in performance
    -- Recursive CTE to get name of category + all its descendants
    WITH Categories AS (
        SELECT Ten
        FROM DANH_MUC
        WHERE Ten LIKE '%' + @Ten_danh_muc + '%'


        UNION ALL


        SELECT CHILD.Ten
        FROM DANH_MUC AS CHILD
            JOIN Categories AS PARENT 
                ON CHILD.Ten_danh_muc_cha = PARENT.Ten
    )


    -- Main SELECT
    SELECT PROD.*


    FROM SAN_PHAM AS PROD
        LEFT JOIN THUONG_HIEU AS BRAN
            ON PROD.Ma_so_thuong_hieu = BRAN.Ma_so
        LEFT JOIN CONG_TY_SAN_XUAT AS MANU
            ON PROD.Ma_so_thue_cong_ty = MANU.Ma_so_thue
        LEFT JOIN DANH_MUC AS CATE
            ON PROD.Ten_danh_muc = CATE.Ten


    -- Subtype joins (LEFT JOIN, so products without subtype rows are still returned)
        LEFT JOIN THUC_PHAM_CHUC_NANG AS TPCN
            ON PROD.Ma_so_san_pham = TPCN.Ma_so_san_pham
        LEFT JOIN DUOC_MY_PHAM AS DMP
            ON PROD.Ma_so_san_pham = DMP.Ma_so_san_pham
        LEFT JOIN THUOC AS THUOC
            ON PROD.Ma_so_san_pham = THUOC.Ma_so_san_pham
        LEFT JOIN CHAM_SOC_CA_NHAN AS CSCN
            ON PROD.Ma_so_san_pham = CSCN.Ma_so_san_pham


    WHERE
        -- keyword search across common text fields
        (
            @Key_word IS NULL
            OR PROD.Ten_san_pham    LIKE '%' + @Key_word + '%'
            OR PROD.Mo_ta_ngan      LIKE '%' + @Key_word + '%'
            OR PROD.Cong_dung       LIKE '%' + @Key_word + '%'
        )


        -- recursive category filter 
        AND (
            @Ten_danh_muc IS NULL
            OR PROD.Ten_danh_muc IN (SELECT Ten FROM Categories)
        )


        -- price filters
        AND (@Gia_toi_thieu IS NULL OR PROD.Gia_tien >= @Gia_toi_thieu)
        AND (@Gia_toi_da IS NULL OR PROD.Gia_tien <= @Gia_toi_da)


        -- subtype/ attribute filters
        AND (
            @Doi_tuong_su_dung IS NULL
            OR TPCN.Doi_tuong_su_dung LIKE '%' + @Doi_tuong_su_dung + '%'
            OR DMP.Doi_tuong_su_dung LIKE '%' + @Doi_tuong_su_dung + '%'
            OR THUOC.Doi_tuong_su_dung LIKE '%' + @Doi_tuong_su_dung + '%'
            OR CSCN.Doi_tuong_su_dung LIKE '%' + @Doi_tuong_su_dung + '%'
        )


        AND (
            @Chi_dinh IS NULL
            OR TPCN.Chi_dinh LIKE '%' + @Chi_dinh + '%'
            OR DMP.Chi_dinh LIKE '%' + @Chi_dinh + '%'
            OR THUOC.Chi_dinh LIKE '%' + @Chi_dinh + '%'
            OR CSCN.Chi_dinh LIKE '%' + @Chi_dinh + '%'
        )


        AND (
            @Loai_Thuoc IS NULL
            OR THUOC.Loai_thuoc = @Loai_thuoc
        )


        AND (
            @Loai_da IS NULL
            OR DMP.Loai_da LIKE '%' + @Loai_da + '%'
            OR CSCN.Loai_da LIKE '%' + @Loai_da + '%'
        )


        AND (
            @Mui_huong IS NULL
            OR TPCN.Mui_vi_huong_vi LIKE '%' + @Mui_huong + '%'
            OR THUOC.Mui_vi_Mui_huong LIKE '%' + @Mui_huong + '%'
            OR CSCN.Mui_vi_Mui_huong LIKE '%' + @Mui_huong + '%'
        )


        -- manufacturer filters
        AND (
            @Nuoc_San_xuat IS NULL
            OR MANU.Quoc_gia LIKE '%' + @Nuoc_san_xuat + '%'
        )


        -- brand filters
        AND (
            @Ten_thuong_hieu IS NULL
            OR BRAN.Ten_thuong_hieu LIKE '%' + @Ten_thuong_hieu + '%'
        )


        AND (
            @Xuat_xu_thuong_hieu IS NULL
            OR BRAN.Xuat_xu LIKE '%' + @Xuat_xu_thuong_hieu + '%'
        )


    -- ORDER BY using safe @SortBy enum (fallback to price_asc)
    ORDER BY 
        CASE WHEN @SortBy = 'price_asc'  THEN PROD.Gia_tien END ASC,
        CASE WHEN @SortBy = 'price_desc' THEN PROD.Gia_tien END DESC,
        CASE WHEN @SortBy = 'name_asc'   THEN PROD.Ten_san_pham END ASC,
        CASE WHEN @SortBy = 'name_desc'  THEN PROD.Ten_san_pham END DESC,
        -- deterministic fallback
        PROD.Ma_so_san_pham


    -- Pagination
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;


    RETURN;


    END TRY


    BEGIN CATCH
        DECLARE 
            @ErrMsg NVARCHAR(4000),
            @ErrSeverity INT;


        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();


        RAISERROR(N'Lỗi khi tìm kiếm/ lọc: %s', @ErrSeverity, 1, @ErrMsg);
        RETURN;


    END CATCH
END
GO

DECLARE @TempSP TABLE 
(
    Ma_so_san_pham    MA_TYPE,
    Ten_san_pham      NVARCHAR(50),
    Luu_y             NVARCHAR(100),
    Gia_tien          TIEN_TYPE,
    Loai_san_pham     INT,
    Don_vi_tinh       NVARCHAR(10),
    Quy_cach          NVARCHAR(50),
    Mo_ta_ngan        NVARCHAR(200),
    Xuat_xu           NVARCHAR(50),
    Ma_so_thue_cong_ty               MA_SO_THUE_TYPE,
    Tac_dung_phu      NVARCHAR(200),
    Ma_so_thuong_hieu MA_TYPE,
    Ten_danh_muc      NVARCHAR(30),
    Cong_dung         NVARCHAR(200),
    Cach_dung         NVARCHAR(200),
    Bao_quan          NVARCHAR(200),
    Ma_so_nhan_vien_kiem_duyet       MA_TYPE,
        /*Trang thai: O -> OnShelf, S-> Shutdown */
    Trang_thai        CHAR          DEFAULT 'O'
    
);

/*
INSERT INTO @TempSP
EXECUTE sp_SearchSanPham 
        @Key_word=N'Hạ sốt',
        @Doi_tuong_su_dung=N'Người lớn',
        @SortBy = 'price_desc';
        
SELECT * FROM @TempSP;        
*/

GO

/* THANH TIEN FUNCTION */
/* Status code 
 * 200 OK
 * 404 Not found
 * 400 Bad data
 */
CREATE OR ALTER FUNCTION fn_CalculateTotalPrice
(
    @Ma_don_hang   MA_TYPE = NULL
)
RETURNS @Result TABLE
(
    Total_price_before_discount     TIEN_TYPE       NOT NULL,
    Final_total_price               TIEN_TYPE       DEFAULT 0.00,
    Freight_rate_before_discount    TIEN_TYPE       NOT NULL,
    Final_freight_rate              TIEN_TYPE       DEFAULT 0.00,
    Status_code                     INT             DEFAULT 200,
    Msg                             VARCHAR(100)    DEFAULT 'Successfull'
)
AS 
BEGIN
    -- SET NOCOUNT ON;


    -- CHECK PARAM --
    IF @Ma_don_hang IS NULL OR
       NOT EXISTS (SELECT 1 FROM DON_HANG WHERE Ma_don_hang = @Ma_don_hang)
    BEGIN
        INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 404, 'Order not found');
        RETURN;
    END


    -- DECLARATION --
    DECLARE @Raw_total_price        TIEN_TYPE = 0.00,
            @Final_total_price      TIEN_TYPE = NULL,
            @Thoi_gian_dat_hang     DATETIME,
            @Raw_freight_rate       TIEN_TYPE = 0.00;


    -- for products in order
    DECLARE @product_table  TABLE
    (
        Ma_so_san_pham      MA_TYPE     PRIMARY KEY,
        So_luong            INT         NOT NULL DEFAULT 0, 
        Gia_tien            TIEN_TYPE   NOT NULL DEFAULT 0.00,
        Gia_sau_hieu_chinh  TIEN_TYPE   NOT NULL DEFAULT 0.00
    );


    -- For looping vouchers
    DECLARE
        @Ma_phieu                        MA_TYPE,
        @Thoi_gian_bat_dau_hieu_luc      DATETIME,
        @Thoi_gian_het_hieu_luc          DATETIME,
        @So_luong_ma                     INT,
        @Gia_don_hang_toi_thieu          TIEN_TYPE,
        @Loai_giam_phan_tram_tien        CHAR, /* P: %, T: Tien */
        @Do_uu_tien                      INT,
        @Cho_don_cho_san_pham            CHAR;
 
    -- INITIALIZATION --
    -- To check order datetime in effective time interval
    SELECT @Thoi_gian_dat_hang = Thoi_gian_dat_hang,
           @Raw_freight_rate = Phi_van_chuyen
    FROM DON_HANG
    WHERE Ma_don_hang = @Ma_don_hang;


    -- Extract all belonging products
    INSERT INTO @product_table (Ma_so_san_pham, So_luong, Gia_tien, Gia_sau_hieu_chinh)
    SELECT GSD.Ma_san_pham, GSD.So_luong, SP.Gia_tien, SP.Gia_tien -- initially
    FROM GOM_SP_DH AS GSD JOIN SAN_PHAM AS SP ON GSD.Ma_san_pham = SP.Ma_so_san_pham
    WHERE GSD.Ma_don_hang = @Ma_don_hang;


    IF NOT EXISTS (SELECT 1 FROM @product_table)
    BEGIN
        INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 404, 'Product not found');
        RETURN;
    END


    -- Raw total price (before any discounts)
    SELECT @Raw_total_price = SUM(So_luong * Gia_tien)
    FROM @product_table;


    -- Iterate each voucher
    DECLARE voucher_cursor CURSOR FOR
        SELECT 
            PGG.Ma_phieu, PGG.Thoi_gian_bat_dau_hieu_luc,
            PGG.Thoi_gian_het_hieu_luc, PGG.So_luong_ma,
            PGG.Gia_don_hang_toi_thieu, PGG.Loai_giam_phan_tram_tien,
            PGG.Do_uu_tien, PGG.Cho_don_cho_san_pham
        FROM AP_MA AS AM JOIN PHIEU_GIAM_GIA AS PGG ON AM.Ma_phieu = PGG.Ma_phieu
        WHERE AM.Ma_don_hang = @Ma_don_hang
        ORDER BY Do_uu_tien ASC;


    OPEN voucher_cursor;
    FETCH NEXT FROM voucher_cursor INTO             
        @Ma_phieu, @Thoi_gian_bat_dau_hieu_luc, 
        @Thoi_gian_het_hieu_luc, @So_luong_ma, 
        @Gia_don_hang_toi_thieu, @Loai_giam_phan_tram_tien, 
        @Do_uu_tien, @Cho_don_cho_san_pham;


    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check cond. meet
        -- Effective datetime
        IF (@Thoi_gian_dat_hang < @Thoi_gian_bat_dau_hieu_luc) OR 
           (@Thoi_gian_dat_hang > @Thoi_gian_het_hieu_luc)
        BEGIN
            INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 400, 'Out of effective time interval');
            CLOSE voucher_cursor;
            DEALLOCATE voucher_cursor;
            RETURN;
        END


        -- Run out of slot
        IF @So_luong_ma <= 0
        BEGIN
            INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 400, 'Run out of slot');
            CLOSE voucher_cursor;
            DEALLOCATE voucher_cursor;
            RETURN;
        END


        IF @Loai_giam_phan_tram_tien NOT IN ('P', 'T')
           OR @Cho_don_cho_san_pham NOT IN ('D', 'S')
        BEGIN
            INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 400, 'Undefined voucher class');
            CLOSE voucher_cursor;
            DEALLOCATE voucher_cursor;
            RETURN;
        END


        -- Load meta data about type-based discount voucher
        DECLARE 
            -- For % discount
            @Phan_tram_giam         DECIMAL(5,2) = 0.00,
            @So_tien_giam_toi_da    TIEN_TYPE = 0.00,
            -- For fixed amount discount
            @So_tien_giam           TIEN_TYPE = 0.00;


        IF @Loai_giam_phan_tram_tien = 'P'
            SELECT @Phan_tram_giam = Phan_tram_giam,
                   @So_tien_giam_toi_da = So_tien_giam_toi_da
            FROM GIAM_GIA_PHAN_TRAM
            WHERE Ma_phieu = @Ma_phieu;
        ELSE
            SELECT @So_tien_giam = So_tien_giam
            FROM GIAM_GIA_TIEN
            WHERE Ma_phieu = @Ma_phieu;


        -- product-level
        IF @Cho_don_cho_san_pham = 'S'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM AP_DUNG WHERE Ma_phieu = @Ma_phieu)
            BEGIN
                INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 404, 'Product not found');
                CLOSE voucher_cursor;
                DEALLOCATE voucher_cursor;
                RETURN;
            END


            -- Check low thresold
            IF EXISTS (
                SELECT 1
                FROM @product_table
                WHERE Ma_so_san_pham IN (SELECT Ma_so_san_pham FROM AP_DUNG WHERE Ma_phieu = @Ma_phieu)
                        AND Gia_sau_hieu_chinh < @Gia_don_hang_toi_thieu
            )
            BEGIN
                INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 400, 'Lower than minimum price');
                CLOSE voucher_cursor;
                DEALLOCATE voucher_cursor;
                RETURN;
            END


            -- Calculate
            UPDATE @product_table
            SET Gia_sau_hieu_chinh = 
                CASE
                    -- decrease overhead in some cases
                    WHEN Gia_sau_hieu_chinh <= 0 THEN 0
                    -- % discount
                    WHEN @Loai_giam_phan_tram_tien = 'P'
                        THEN GREATEST(Gia_sau_hieu_chinh - LEAST(Gia_sau_hieu_chinh * @Phan_tram_giam, @So_tien_giam_toi_da), 0) 
                    -- fixed amount discount
                    ELSE GREATEST(Gia_sau_hieu_chinh - @So_tien_giam, 0)
                END
            WHERE Ma_so_san_pham IN (SELECT Ma_so_san_pham FROM AP_DUNG WHERE Ma_phieu = @Ma_phieu);
        END


        -- order-level
        ELSE IF @Cho_don_cho_san_pham = 'D'
        BEGIN
            DECLARE @Current_sub TIEN_TYPE = (
                SELECT SUM(So_luong * Gia_sau_hieu_chinh)
                FROM @product_table
            );


            IF @Gia_don_hang_toi_thieu > @Current_sub
            BEGIN
                INSERT INTO @Result VALUES (0.00, 0.00, 0.00, 0.00, 400, 'Lower than minimum price');
                CLOSE voucher_cursor;
                DEALLOCATE voucher_cursor;
                RETURN;
            END


            -- Calculate
            IF @Final_total_price IS NULL
                SET @Final_total_price = @Current_sub;


            SET @Final_total_price = 
                CASE
                -- decrease overhead in some cases
                    WHEN @Final_total_price <= 0 THEN 0
                    -- % discount
                    WHEN @Loai_giam_phan_tram_tien = 'P'
                        THEN GREATEST(@Final_total_price - LEAST(@Final_total_price * @Phan_tram_giam, @So_tien_giam_toi_da), 0) 
                    -- fixed amount discount
                    ELSE GREATEST(@Final_total_price - @So_tien_giam, 0)
                END;
        END


        -- next voucher
        FETCH NEXT FROM voucher_cursor INTO             
            @Ma_phieu, @Thoi_gian_bat_dau_hieu_luc, 
            @Thoi_gian_het_hieu_luc, @So_luong_ma, 
            @Gia_don_hang_toi_thieu, @Loai_giam_phan_tram_tien, 
            @Do_uu_tien, @Cho_don_cho_san_pham;


    END -- WHILE


    CLOSE voucher_cursor;
    DEALLOCATE voucher_cursor;


    -- Calculate final total price
    DECLARE @Freight_rate_discount      TIEN_TYPE = 0.00;


    -- product level
    IF @Final_total_price IS NULL
    BEGIN
        SELECT @Final_total_price = GREATEST(SUM(So_luong * Gia_sau_hieu_chinh), 0)
        FROM @product_table;
    END


     -- freight rate BASED ON FINAL PRICE
    IF @Final_total_price > 500
        SET @Freight_rate_discount = @Raw_freight_rate;


    INSERT INTO @Result
    (
        Total_price_before_discount, Final_total_price,
        Freight_rate_before_discount, Final_freight_rate,
        Status_code, Msg
    )
    SELECT
        Total_price_before_discount = @Raw_total_price,
        Final_total_price = @Final_total_price,
        Freight_rate_before_discount = @Raw_freight_rate,
        Final_freight_rate = @Raw_freight_rate - @Freight_rate_discount,
        Status_code = 200,
        Msg = 'Successfull';


    -- Successfully
    RETURN;
END
GO 

