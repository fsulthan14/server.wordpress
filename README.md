# 🚀 How To Use `server.wordpress` Scripts  

## 📌 System Requirements  
Pastikan server memenuhi spesifikasi minimum berikut:  

- **OS**: Ubuntu 22.04  
- **RAM**: 2 GB  
- **Disk**: 32 GB  
- **CPU**: 2 Cores  

---

## 🔧 Installation Guide  

### **1️⃣ Install with Default Options**  
Gunakan perintah berikut untuk instalasi cepat dengan opsi default:  
```bash
sudo /tmp/server.wordpress/install.sh /opt ledig ledigstudio.com LedigStudio backup-ledigstudio qihh.sulthan@gmail.com YourEmailPass
```

### **2️⃣ Install with Custom Options**  
Gunakan perintah berikut untuk instalasi dengan konfigurasi yang lebih spesifik:  
```bash
sudo /tmp/server.wordpress/install.sh /opt ledig ledigstudio.com LedigStudio backup-ledigstudio qihh.sulthan@gmail.com YourEmailPass true subdomain 8.2
```

---

## ⚙️ Parameter Explanation  
| Parameter | Contoh Nilai | Deskripsi |
|-----------|-------------|-----------|
| `/opt` | `/opt` | Path instalasi WordPress |
| `ledig` | `ledig` | Nama pengguna server |
| `ledigstudio.com` | `ledigstudio.com` | Domain utama WordPress |
| `LedigStudio` | `LedigStudio` | Nama situs WordPress |
| `backup-ledigstudio` | `backup-ledigstudio` | Nama database WordPress |
| `qihh.sulthan@gmail.com` | `qihh.sulthan@gmail.com` | Email admin WordPress |
| `YourEmailPass` | `password123` | Password email admin |
| `true` | `true` / `false` | Aktifkan Multisite (default: `false`) |
| `subdomain` | `subdomain` / `subdir` | Mode Multisite |
| `8.2` | `8.2` / `7.4` | Versi PHP yang digunakan |

---

## 📂 **Admin Credentials & Password Reset**  
Setelah instalasi selesai, cek file berikut untuk mendapatkan informasi akun admin dan pengguna:  
📌 **File Lokasi:** `/var/local/admin.txt`  
```bash
cat /var/local/admin.txt
```
⚠️ **Segera lakukan reset password admin setelah instalasi selesai untuk keamanan!**  

---

📢 **Sekarang server WordPress Anda siap digunakan!** 🎉  
```
