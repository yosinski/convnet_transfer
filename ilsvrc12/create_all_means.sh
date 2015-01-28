#! /bin/bash -x

IMAGENET_DIR=/set/path/to/imagenet/directory
CAFFE_TOOLS_DIR=/set/path/to/caffe/build/tools/directory

create_tv ()
{
    submit GLOG_logtostderr=1 $CAFFE_TOOLS_DIR/compute_image_mean.bin data/${1}_train/leveldb data/${1}_train/mean.binaryproto
    submit GLOG_logtostderr=1 $CAFFE_TOOLS_DIR/compute_image_mean.bin data/${1}_valid/leveldb data/${1}_valid/mean.binaryproto
}

create_train ()
{
    submit GLOG_logtostderr=1 $CAFFE_TOOLS_DIR/compute_image_mean.bin data/${1}_train/leveldb data/${1}_train/mean.binaryproto
}

submit ()
{
    echo "This will only work on a cluster supporting qsub. Modify if needed for your setup."

    jobname="mn_`date +%H%M%S`"
    echo "#! /bin/bash" >> $jobname.sh
    echo "$@" >> $jobname.sh
    chmod +x $jobname.sh
    qsub -N "$jobname" -A ACCOUNT_NAME -l nodes=1:ppn=2 -l walltime=8:00:00 -d `pwd` $jobname.sh
    sleep 1.5
}

# A/B halves
create_tv half0A
create_tv half0B
create_tv half1A
create_tv half1B
create_tv half2A
create_tv half2B
create_tv half3A
create_tv half3B

# Natural/Man-made halves
create_tv halfnatmanA
create_tv halfnatmanB

# Reduced volume datasets
create_train reduced0001
create_train reduced0002
create_train reduced0005
create_train reduced0010
create_train reduced0025
create_train reduced0050
create_train reduced0100
create_train reduced0250
create_train reduced0500
create_train reduced0750
create_train reduced1000
