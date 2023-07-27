clc, clear all;
% Saç Seçimi
Aw = 468.75; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d = 25; % mm %%%%%%%%%%%%%%%%%%%%% SAC SECIMI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e = 50; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AwList = [468.75 483.87 507 588 768 918.75 972 1090.61 1200 1323 1478.52 1518.75 1875 2187 2436.75 2523 2700 3072];
dList = [25 25.4 26 28 32 35 36 38.1 40 42 44.4 45 50 54 57 58 60 64];
eList = [50 50.8 52 56 64 70 72 76.3 80 84 88.8 90 100 108 114 116 120 128];
SacList =["EI 75" "EI 76" "EI 78" "EI 84" "EI 96" "EI 105" "EI 108" "EI 114" "EI 120" "EI 126" "EI 133" "EI 135" "EI 150" "EI 162" "EI 171" "EI 174" "EI 180" "EI 192"];
% BASLANGIC KOSULLARI
S2n = 23 ; % VA çıkış gücü
V1n = 220 ; % V
V2n = 24; % V
Bm = 1.2; % T
f = 50; %Hz
Reg = 0.02 ;
J = 4e6 ; % A/m^2
Verim = 0.90;
Kf = 1.11; % Şekil Faktörü
Ku = 0.17; % Pencere Kullanım Faktörü
Ks = 0.95; % Sac Paketleme Faktörü

S1n = S2n/Verim; % VA Giriş Gücü
St = S1n+S2n; % VA Güç Aktarma Kabiliyeti

Ap = St/(4*Kf*Ku*Bm*f*J); % m^4 Alanlar Çarpımı
Apcm = Ap*1e8; % cm Cinsinden
Apmm = Ap*1e12; % mm Cinsinden
% EI 75 saçı seçildi

for i = 1:length(AwList)
    % Demir Göbek Kesiti
    Acmm = Apmm/AwList(i); % mm^2 Cinsinden
    Accm = Acmm*1e-2; % cm^2 Cinsinden
    Ac = Accm*1e-6; % m^2 Cinsinden
    
    % Göbek Boyutlarınının Belirlenmesi
    d2 = Acmm/dList(i); % Sacın uzunlugu
    SacSayisi = round(d2/0.5); % Kullanılacak Sac Sayısı
    d2y = SacSayisi * 0.5;
    
    Acymm = dList(i)*d2y; % mm^2 Cinsinden Yeni Ac
    Acycm = Acymm*1e-2; % cm^2 Cinsinden
    Acy = Acymm*1e-6; % m^2 Cinsinden
    
    % Sarım Sayılarının Hesaplanması
    Nt = 1/(4*Kf*Bm*Acy*f); % Volt Başına Sarım Sayısı
    N1 = round(V1n*Nt); % Primer Sarım Sayısı
    N2 = round((1+Reg)*V2n*Nt); % Sekonder Sarım Sayısı
    a = N1/N2; % Çevirme Oranı
    
    % Akımların Hesabı
    I1n = S1n/V1n; % Primer Akımı
    I2n = S2n/V2n; % Sekonder Akımı
    
    % Tel Çaplarının Hesabı
        % Primer Teli
    q1 = I1n/(J*1e-6); 
    D1 = sqrt((4*q1)/pi); % Primer Tel Çapı mm^2 Cinsinden
    D1y = 0.19; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D1e = 0.22; %%%%%%%%%%%%%%%%% TEL SECIMI 1 %%%%%%%%%%%%%%%%%%%%%%%
        % Sekonder Teli
    q2 = I2n/(J*1e-6);
    D2 = sqrt((4*q2)/pi); % Sekonder Tel Çapı mm^2 Cinsinden
    D2y = 0.55; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D2e = 0.6; %%%%%%%%%%%%%%%%% TEL SECIMI 2 %%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Bobin Sargılarının Ne Kadar Kabarıcağının Belirlenmesi
    KPK = 1; % mm Presbantın Kalınlıgı
    HTOL = 0.5; % mm Alt veÜst Tolerans Miktarı
    c = 37.5; % Tablodan Bakılan c  Değeri
    cmi = c-2*HTOL-4*KPK; % mm Makara İç Genişliği
    
    % Primer Sargı Kabarmasının Hesabı
    YPIS = floor(cmi/D1e); % Adet İletken Yan Yana Yerleşir
    PKS = ceil(N1/YPIS); % Primer Kat Sayısı
    APK = 0.15; % mm
    hp = PKS * D1e + (PKS-1)*APK; % mm Primer Sargı Yüksekliği
    
    % Sekonder Sargı Kabarmasının Hesabı
    YSIS = floor(cmi/D2e); % Adet İletken Yan Yana Yerleşir
    SKS = ceil(N2/YSIS); % Sekonder Kat Sayısı
    hs = SKS * D2e + (SKS-1)*APK; % mm Sekonder Sargı Yüksekliği
    
    OPK = 0.3; % mm
    SPK = OPK;
    WTOL = 2; % mm
    ht = KPK+hp+OPK+hs+SPK+WTOL; % mm Toplam Sargı Yüksekliği
    
    % KONTROL
    
    c2 = (eList(i)-dList(i))/2; %mm Saçın Pencere Yüksekliği
    if c2 > ht
        disp(SacList(i) + " -> Kontrol Edildi Onaylandı! " + "| ht = " + ht + " | c2 = " + c2)
    else
        disp(SacList(i) + " -> Başarısız! " + "| ht = " + ht + " | c2 = " + c2)
    end
end
% Bobinin Makarasının Ölçüleri
% Bobin makarası iç ölçüleri
MTOL = 0.25; %mm
dm = d + MTOL;
dm2 = (d2y/Ks)+MTOL;
KK = c2-KPK-HTOL; % mm Kapak kenar uzunluğu
MKD1 = e - 2*HTOL;
MKD2 = dm2 + 2*KPK + 2*KK; %mm Kapak dış boyutları
Hm = c -4*KPK - HTOL;
MGKY1 = dm + (KPK)/2; % Makara gövde katlanma yeri 1
MGKY2 = dm2 + (KPK)/2; % Makara gövde katlanma yeri 2


