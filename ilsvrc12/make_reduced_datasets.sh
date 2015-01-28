#! /bin/bash

# Creates all reduced datasets

#echo "Remove this line if you're sure you want to run (overwrites some data files)" && exit 1

set -e

make_half ()
{
    seed="$1"
    tv="$2"
    ./make_reduced_dataset.py --seed ${seed} data/whole_${tv}/files.txt
    mkdir -p data/half${seed}A_${tv}
    mkdir -p data/half${seed}B_${tv}
    mv reduced_A.txt        data/half${seed}A_${tv}/files.txt
    mv reduced_A_idxmap.txt data/half${seed}A_${tv}/idxmap.txt
    mv reduced_B.txt        data/half${seed}B_${tv}/files.txt
    mv reduced_B_idxmap.txt data/half${seed}B_${tv}/idxmap.txt
}

make_half_tv ()
{
    make_half $1 train
    make_half $1 valid
}

make_half_from_files ()
{
    fileA="$1"
    fileB="$2"
    name="$3"
    tv="$4"
    ./make_reduced_dataset.py --half-files "$fileA" "$fileB" data/whole_${tv}/files.txt
    mkdir -p data/half${name}A_${tv}
    mkdir -p data/half${name}B_${tv}
    mv reduced_A.txt        data/half${name}A_${tv}/files.txt
    mv reduced_A_idxmap.txt data/half${name}A_${tv}/idxmap.txt
    mv reduced_B.txt        data/half${name}B_${tv}/files.txt
    mv reduced_B_idxmap.txt data/half${name}B_${tv}/idxmap.txt
}

make_half_from_files_tv ()
{
    make_half_from_files "$1" "$2" "$3" train
    make_half_from_files "$1" "$2" "$3" valid
}

make_reduced ()
{
    number="$1"
    tv="$2"
    ./make_reduced_dataset.py --perclass "$number" data/whole_${tv}/files.txt
    mkdir -p data/reduced${number}_${tv}
    mv reduced.txt        data/reduced${number}_${tv}/files.txt
}

# Random split datasets
make_half_tv 0
make_half_tv 1
make_half_tv 2
make_half_tv 3

# Natural vs. Manmade split datasets
make_half_from_files_tv data/half_nat_idx.txt data/half_man_idx.txt natman

# Reduced size Datasets
make_reduced 1000 train
make_reduced 0750 train
make_reduced 0500 train
make_reduced 0250 train
make_reduced 0100 train
make_reduced 0050 train
make_reduced 0025 train
make_reduced 0010 train
make_reduced 0005 train
make_reduced 0002 train
make_reduced 0001 train



# If all went well, and random seeds behave the same way on your system as on mine, the following files should be created:

# $ cd data
#
# $ md5sum *train/files.txt
# 83f4e664c68213ba43dd9b4465dd7d4e  half0A_train/files.txt
# 0a9e2917a5f10bdbf22974f4b1fc17ce  half0B_train/files.txt
# 8926a880165726455c5639e4813a2d3b  half1A_train/files.txt
# b95d534d95151f4fae7610d25d6377fd  half1B_train/files.txt
# 61ffa67fe88e307ac1c5639a087fdf1b  half2A_train/files.txt
# ddda030205cfd7960498d9300f5c3deb  half2B_train/files.txt
# 32369aaeb73012881558f0f16d932b95  half3A_train/files.txt
# 0017c6f301f33db91008663985b6f826  half3B_train/files.txt
# 5fb4569a4f3be3897f490ee21b356256  halfnatmanA_train/files.txt
# 4ba839156cd6c7f33d8ada94e4331887  halfnatmanB_train/files.txt
# 803a36f02b511db01532a604f5704ea8  reduced0001_train/files.txt
# af6addb779610611d460f0ade2931f2f  reduced0002_train/files.txt
# abdce3ff7f7933b0323c1074de7a734d  reduced0005_train/files.txt
# d3752c71b0facde0173876293ce632fd  reduced0010_train/files.txt
# df313d05c0256010b96870f5707f0417  reduced0025_train/files.txt
# 34e5285b75e5448ff82bc6b0ca0c28f7  reduced0050_train/files.txt
# 8376e82b043586424b8bebf4fd4a8af2  reduced0100_train/files.txt
# e83abe901d08926ef62956be8628dbd0  reduced0250_train/files.txt
# d32ff1c8817548f0edf5557b32ca5e0e  reduced0500_train/files.txt
# 5bb58aecc081ec6c27ec68bbc755bb58  reduced0750_train/files.txt
# 94fce01f9b4cb80bdb3fbf2a440c26e6  reduced1000_train/files.txt
# 3be8e5d8cbd932cc295ec175d5110921  whole_train/files.txt
# 
# $ md5sum *valid/files.txt
# 2f10009e20d77eb7007cf70674958b94  half0A_valid/files.txt
# cce39b383d681345c873faf2c0c28d33  half0B_valid/files.txt
# 9ab48b6420504e32ff4498e7d8569f8b  half1A_valid/files.txt
# 57522f5e2aa69547846089f5197c8a6b  half1B_valid/files.txt
# 03d05b6565ab9176baccdd05d746bfd1  half2A_valid/files.txt
# 18de8b37378e07e60dc602b6130eeeb2  half2B_valid/files.txt
# 46086440ddde128f169f23331998499d  half3A_valid/files.txt
# e5f9f0895fd0d49a8ac0b804ec891282  half3B_valid/files.txt
# 4fb63c72229ba07106a558127192cb9f  halfnatmanA_valid/files.txt
# f03be5732fb6bc7928ee53397b043613  halfnatmanB_valid/files.txt
# b6284a7c08fba47457c2c1f6049a156e  whole_valid/files.txt
