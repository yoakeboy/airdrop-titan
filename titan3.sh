#!/bin/bash

# Periksa apakah skrip dijalankan sebagai pengguna root
if [ "$(id -u)" != "0" ]; then
    echo "Skrip ini harus dijalankan dengan izin pengguna root."
    echo "Silakan coba gunakan perintah 'sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi."
    exit 1
fi
clear
echo "Saya cuma modif source code"
echo "Telegram @nugz5"
echo "=========================Titan Node================================"

# Minta input dari pengguna
read -p "Masukkan Code Identity Anda: " id
read -p "Masukkan Size Disk GB (misalnya 100): " storage
clear
# Update paket repository
apt update

# Centang jika Docker diinstal 
if ! command -v docker &> /dev/null; then
    echo "Docker tidak terdeteksi, menginstal..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # Instal Docker versi terbaru
    apt-get install docker.io -y
else
    clear
    echo "Docker telah diinstal."
fi

# Tarik gambar Docker
docker pull nezha123/titan-edge

# Buat direktori untuk volume bind
mkdir -p ~/.titanedge

# Jalankan container dan simpan ID kontainer yang dibuat
container_id=$(docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge)
clear
echo "Node Titan telah sukses dibuat"

# Tunggu beberapa saat untuk memastikan kontainer siap
sleep 10

# Ubah file config.toml untuk mengatur nilai StorageGB dan alamat listening
docker exec $container_id titan-edge config set --storage-size "${storage}GB"
docker exec $container_id titan-edge config set --listen-address 0.0.0.0:9000

# Masuk ke dalam container dan lakukan pengikatan Order
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding
clear
# Mulai ulang kontainer agar pengaturan diterapkan
echo "ID CONTAINER"
docker restart $container_id
echo "Node Titan berhasil terikat dengan IDENTITY CODE."

sleep 10
echo "===========================SHOW CONFIG=============================="
docker exec $container_id titan-edge config show
sleep 10
echo "=========================SHOW NODE INFO============================="
docker exec $container_id titan-edge info
sleep 5
echo "====================NODE TELAH SUKSES BERJALAN======================"
clear

# Menambahkan pilihan untuk melihat log atau keluar dari skrip
read -p "Apakah Anda ingin melihat log container? (ketik '1' untuk melihat log, atau tekan enter untuk keluar): " choice

if [ "$choice" = "1" ]; then
    # Membuat session tmux dengan nama "titan" dan menjalankan perintah untuk melihat log
    tmux new-session -d -s titan "docker logs -f -t $container_id"
    echo "Sesi 'titan' telah dibuat untuk melihat log container."
    echo "Anda dapat masuk ke sesi dengan menjalankan 'tmux attach-session -t titan'."
    echo "Untuk keluar dari sesi tekan 'CTRL + b' lalu tekan 'd'"
else
    echo "Terima kasih telah menggunakan skrip ini. Sampai jumpa!"
fi
