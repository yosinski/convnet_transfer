#! /usr/bin/env python

import argparse
from numpy import *




def makeit(old_idx, in_filename, out_prefix):
    assert sorted(old_idx) == old_idx, 'Must be in order'

    set_old_idx = set(old_idx)
    new_idx = range(len(old_idx))   # New is 0...max
    map_old_to_new = dict(zip(old_idx, new_idx))
    map_new_to_old = dict(zip(new_idx, old_idx))

    in_file = open(in_filename)
    out_file = open(out_prefix + '.txt', 'w')

    for line in in_file:
        jpg_file, old_class = line.split()
        old_class = int(old_class)
        if old_class in set_old_idx:
            new_class = map_old_to_new[old_class]
            out_file.write('%s %d\n' % (jpg_file, new_class))

    in_file.close()
    out_file.close()

    with open(out_prefix + '_idxmap.txt', 'w') as ff:
        ff.write('# Orig_idx new_idx\n')
        for oo,nn in zip(old_idx, new_idx):
            ff.write('%d %d\n' % (oo,nn))



def makeit_keep_first_n(nn, in_filename, out_prefix):
    '''Keep all classes but only the first nn examples of each class.'''

    in_file = open(in_filename)
    out_file = open(out_prefix + '.txt', 'w')

    n_seen = [0]*1000
    
    for line in in_file:
        jpg_file, class_idx = line.split()
        class_idx = int(class_idx)
        if n_seen[class_idx] < nn:
            n_seen[class_idx] = n_seen[class_idx] + 1
            out_file.write('%s %d\n' % (jpg_file, class_idx))

    in_file.close()
    out_file.close()



def main():
    parser = argparse.ArgumentParser(description='Creates reduced datasets. There are three modes: random A/B, splits from half-files, and reduction by limited n.')
    #parser.add_argument('--show', action = 'store_true',
    #                    help = 'Show plots as well (default: off)')
    parser.add_argument('-s', '--seed', type = int, nargs=1, default=[0],
                        help = 'Which seed to use (default: 0)')
    parser.add_argument('-o', '--outprefix', type = str, default='reduced',
                        help = 'Prefix of output file, produces PREFIX_A.txt and PREFIX_A_idxmap.txt (default: reduced)')
    parser.add_argument('-hf', '--half-files', type = str, nargs=2,
                        help = 'Use the given input file instead of randomly shuffling files (default: off)')
    parser.add_argument('-p', '--perclass', type = int, nargs=1,
                        help = 'Limit the number of examples per class to this number')
    parser.add_argument('infile', type = str,
                        help = 'Input filename.')
    args = parser.parse_args()

    if args.perclass:
        print 'Mode: Per class with number', args.perclass
        makeit_keep_first_n(args.perclass[0], args.infile, args.outprefix)
    else:
        if args.half_files:
            print 'Mode: Using half files', args.half_files
            with open(args.half_files[0]) as ff:
                groupAOldIdx = sorted([int(line.strip()) for line in ff])
            with open(args.half_files[1]) as ff:
                groupBOldIdx = sorted([int(line.strip()) for line in ff])
            allOldIdx = sorted(groupAOldIdx + groupBOldIdx)
            assert allOldIdx == range(1000), 'missing some indices; expected range(1000) but got %s' % repr(allOldIdx)
        else:
            print 'Mode: Randomly splitting with seed', args.seed[0]

            random.seed(args.seed)

            # FIRST: A/B split!
            idx = arange(1000)   # class indices
            groupAOldIdx = sorted(random.choice(idx, 500, replace=False))
            groupBOldIdx = sorted(list(set(idx)-set(groupAOldIdx)))


        makeit(groupAOldIdx, args.infile, args.outprefix + '_A')
        makeit(groupBOldIdx, args.infile, args.outprefix + '_B')
        #makeit(range(1000), args.infile, args.outprefix)



if __name__ == '__main__':
    main()
