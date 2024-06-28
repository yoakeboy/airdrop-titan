#!/bin/bash

# Periksa apakah skrip dijalankan sebagai pengguna root
if [ "$(id -u)" != "0" ]; then
    echo "Skrip ini harus dijalankan dengan izin pengguna root."
    echo "Silakan coba gunakan perintah 'sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi."
    exit 1
fi

echo "Saya Hanya Translate Source @y95277777"
echo "======================Titan Node============================="

# Set nilai default
id="48B11EF5-735C-4271-8371-326F295492C7"

apt update

# Centang jika Docker diinstal 
if ! command -v docker &> /dev/null
then
    echo "Docker tidak terdeteksi, menginstal..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # Instal Docker versi terbaru
    apt-get install docker.io -y
else
    echo "Docker telah diinstal."
fi

# Tarik gambar Docker
docker pull nezha123/titan-edge

# Jalankan container dan simpan ID kontainer yang dibuat
container_id=$(docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge)

echo "Node Titan telah sukses dibuat"

sleep 5

# Ubah file config.toml host untuk mengatur nilai StorageGB dan port
docker exec $container_id titan-edge config set --storage-size 200GB
docker exec $container_id titan-edge daemon stop
docker exec $container_id titan-edge daemon start

# Masuk ke container dan lakukan pengikatan Order
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding
echo "Node titan terikat."

# Mulai ulang wadah agar pengaturan diterapkan 
docker restart $container_id

echo "===========================Semua node telah disiapkan dan dimulai==========================="
