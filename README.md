## How transferable are features in deep neural networks?


This repository contains source code necessary to reproduce the results presented in the following paper:

```
@inproceedings{yosinski_2014_NIPS
  title={How transferable are features in deep neural networks?},
  author={Yosinski, Jason and Clune, Jeff and Bengio, Yoshua and Lipson, Hod},
  booktitle={Advances in Neural Information Processing Systems 27 (NIPS '14)},
  editor = {Z. Ghahramani and M. Welling and C. Cortes and N.D. Lawrence and K.Q. Weinberger},
  publisher = {Curran Associates, Inc.},
  pages = {3320--3328},
  year={2014}
}
```

The are four steps to using this codebase to reproduce the results in the paper.

 * Assemble prerequisites
 * Create datasets
 * Train models
 * Gather and plot results

Each is described below. Training results are also provided in the
`results` directory for those just wishing to compare results to their
own work without undertaking the arduous training process.



## Assemble prerequisites

Several dependencies should be installed.

 * To run experiments: [Caffe](http://caffe.berkeleyvision.org/) and its relevant dependencies (see [install tutorial](http://caffe.berkeleyvision.org/installation.html)).
 * To produce plots: the IPython, numpy, and matplotlib packages for python. Depending on your setup, it may be possible to install these via `pip install ipython numpy matplotlib`.



## Create Datasets

**1. Obtain ILSVRC 2012 dataset**

The ImageNet Large Scale Visual Recognition Challenge (ILSVRC) 2012 dataset can be downloaded [here](http://image-net.org/challenges/LSVRC/2012/index) (registration required).

**2. Create derivative dataset splits**

The necessary smaller derivative datasets (random halves, natural and man-made halves, and reduced volume versions) can be created from the raw ILSVRC12 dataset.

```
$ cd ilsvrc12
$ ./make_reduced_datasets.sh
```

The script will do most of the work, including setting random seeds to hopefully produce the exact same random splits used in the paper. Md5sums are listed for each dataset file at the bottom of `make_reduced_datasets.sh`, which can be used to verify the match. Results may vary on different platforms though, so don't worry too much if your sums don't match.

**3. Convert datasets to databases**

The datasets created above are so far just text files providing a list of image filenames and class ids. To train a Caffe model, they should be converted to a LevelDB or LMDB, one per dataset. See the [Caffe ImageNet Tutorial](http://caffe.berkeleyvision.org/gathered/examples/imagenet.html) for a more in depth look at this process.

First, edit `create_all_leveldbs.sh` and set the `IMAGENET_DIR` and `CAFFE_TOOLS_DIR` to point to the directories containing the ImageNet image files and compiled caffe tools (like `convert_imageset.bin`), respectively. Then run:

```$ ./create_all_leveldbs.sh```

This step takes a lot of space (and time), approximately 230 GB for the base training dataset, and on average 115 GB for each of the 10 split versions, for a total of about 1.5 TB. If this is prohibitive, you might consider using a different type of data layer type for Caffe that loads images directly from a single shared directory.

**4. Compute the mean of each dataset**

Again, edit the paths in the script to point to the appropriate locations, and then run:

```
$ ./create_all_means.sh
```

This just computes the mean of each dataset and saves it in the dataset directory. Means are subtracted from input images during training and inference.



## Train models

A total of 163 networks were trained to produce the results in the
paper. Many of these networks can be trained in parallel, but because
weights are transferred from one network to another, some must be
trained serially. In particular, all networks in the first block below
must be trained before any in the second block can be trained. All
networks within a block may be trained at the same time. The
"whenever" block does not contain dependencies and can be trained any
time.

```
Block: one
  half*       (10 nets)

Block: two
  transfer*   (140 nets)

Block: whenever
  netbase     (1 net)
  reduced-*   (12 nets)
```

To train a given network, change to its directory, copy (or symlink)
the required caffe executable, and run the training procedure. This
can be accomplished using the following commands, demonstrated for the
`half0A` network:

```
$ cd results/half0A
$ cp /path/to/caffe/build/tools/caffe.bin .
$ ./caffe.bin train -solver imagenet_solver.prototxt
```

Repeat this process for all networks in `block: one` and `block:
whenever` above. Once the networks in `block: one` are trained, train
all the networks in `block: two` similarly. This time the command is
slightly different, because we need to load the base network in order
to fine-tune it on the target task. Here's an example for the
`transfer0A0A_1_1` network:

```
$ cd results/transfer0A0A_1_1
$ cp /path/to/caffe/build/tools/caffe.bin .
$ ./caffe.bin train -solver imagenet_solver.prototxt -weights basenet/caffe_imagenet_train_iter_450000
```

The `basenet` symlinks have been added to point to the appropriate
base network, but the `basenet/caffe_imagenet_train_iter_450000` file
will not exist until the relevant `block: one` networks has been trained.

**Training notes:** while the above procedure should work if followed
literally, because each network takes about 9.5 days to train (on a
K20 GPU), it will be much faster to train networks in parallel in a
cluster environment. To do so, create and submit jobs as appropriate
for your system. You'll also want to ensure that the output of the
training procedure is logged, either by piping to a file

```
$ ./caffe.bin train ... > log_file 2>&1
```

or via whatever logging facilities are supplied by your cluster or job
manager setup.



## Plot results

Once the networks are trained, the results can be plotted using the included IPython notebook `plots/transfer_plots.ipynb`.
Start the IPython Notebook server:

```
$ cd plots
$ ipython notebook
```

Select the `transfer_plots.ipynb` notebook and execute the included code. Note that without modification,
the code will load results from the saved log files included in this
repository. If you've run your own training and wish to plot those log
files, change the paths in the "Load all the data" section to point to
your log files instead.

Or, to skip all the work and just see the results, you can take a look at [this notebook with cached plots](http://nbviewer.ipython.org/url/yosinski.cs.cornell.edu/transfer_plots.ipynb).



## Questions?

Please drop [me](http://yosinski.com/) a line if you have any questions!













