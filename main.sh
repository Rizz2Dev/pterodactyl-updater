#!/bin/bash

# Fungsi untuk melakukan update panel Pterodactyl
update_panel() {
    echo "Memulai proses update panel Pterodactyl..."

    # Masuk ke direktori Pterodactyl
    cd /var/www/pterodactyl || exit

    # Matikan aplikasi Pterodactyl
    php artisan down

    # Unduh dan ekstrak versi terbaru dari GitHub
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

    # Atur izin untuk direktori storage dan cache
    chmod -R 755 storage/* bootstrap/cache

    # Install dependensi Composer
    composer install --no-dev --optimize-autoloader

    # Bersihkan view dan konfigurasi cache
    php artisan view:clear
    php artisan config:clear

    # Lakukan migrasi database dengan seeding dan memaksa prosesnya
    php artisan migrate --seed --force

    # Atur ulang kepemilikan file untuk www-data (user web server)
    chown -R www-data:www-data /var/www/pterodactyl/*

    # Restart antrian PHP artisan
    php artisan queue:restart

    # Nyalakan kembali aplikasi Pterodactyl
    php artisan up

    echo "Update panel Pterodactyl selesai."
}

# Fungsi untuk melakukan update Wings
update_wings() {
    echo "Memulai proses update Wings..."

    # Mengunduh dan menginstal Wings terbaru
    curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
    chmod +x /usr/local/bin/wings

    echo "Update Wings selesai."
}

# Menampilkan menu opsi
echo "Menu:"
echo "1. Update panel Pterodactyl"
echo "2. Update Wings Pterodactyl"
echo "3. Keluar"

# Membaca pilihan pengguna
read -p "Masukkan pilihan Anda: " choice

# Memproses pilihan pengguna
case $choice in
    1)
        update_panel
        ;;
    2)
        update_wings
        ;;
    3)
        echo "Keluar dari skrip."
        exit 0
        ;;
    *)
        echo "Pilihan tidak valid. Silakan masukkan pilihan yang benar."
        ;;
esac
