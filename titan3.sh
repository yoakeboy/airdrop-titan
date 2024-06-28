#!/bin/bash

# Periksa apakah skrip dijalankan sebagai pengguna root
if [ "$(id -u)" != "0" ]; then
    echo "Skrip ini harus dijalankan dengan izin pengguna root."
    echo "Silakan coba gunakan perintah 'sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi."
    exit 1
fi

echo "Saaya cuma modif source code"
echo "======================Titan Node============================="

# Minta input dari pengguna
read -p "Masukkan Code Identity Anda: " id
read -p "Masukkan jumlah disk (misalnya 200GB): " storage_gb

# Update paket repository
apt update

# Centang jika Docker diinstal 
if ! command -v docker &> /dev/null; then
    echo "Docker tidak terdeteksi, menginstal..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # Instal Docker versi terbaru
    apt-get install docker.io -y
else
    echo "Docker telah diinstal."
fi

# Tarik gambar Docker
docker pull nezha123/titan-edge

# Buat direktori untuk volume bind
mkdir -p ~/.titanedge

# Jalankan container dan simpan ID kontainer yang dibuat
container_id=$(docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge)
echo "Node Titan telah sukses dibuat"

# Tunggu beberapa saat untuk memastikan kontainer siap
sleep 10

# Ubah file config.toml untuk mengatur nilai StorageGB dan alamat listening
docker exec $container_id titan-edge config set --storage-size $storage_gb
docker exec $container_id titan-edge config set --listen-address 0.0.0.0:9000

# Masuk ke dalam container dan lakukan pengikatan Order
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding
echo "Node titan terikat."

# Mulai ulang kontainer agar pengaturan diterapkan
docker restart $container_id
echo "Kontainer telah berhasil direstart."

echo "===========================Semua node telah disiapkan dan dimulai==========================="
