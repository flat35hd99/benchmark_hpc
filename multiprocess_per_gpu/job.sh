#!/bin/bash -eu
#PBS -l select=1:ncpus=4:ompthreads=1
#PBS -l walltime=6:00:00

prefix=$PREFIX_BENCHMARK_HPC
prefix_input=$prefix/input_data
prefix_bench=$prefix/multiprocess_per_gpu
FAST_WORKING_DIR=/lwork/users/$USER/$PBS_JOBID
PMEMD=pmemd

# Input ----------

n_times=1

# ----------------

module purge
module load amber/22u1

for n_procs in "1" "2" "4" "8" "16" "32";do
  mkdir -p $prefix_bench/output/procs_${n_proc}
  for i_time in `seq 1 ${n_times}`;do
    mkdir -p $prefix_bench/output/procs_${n_proc}/time_${i_time}
    start_time=`date +%s`
    for i_proc in `seq 1 ${n_procs}`;do
      mkdir $FAST_WORKING_DIR/$i_proc
      cd $FAST_WORKING_DIR/$i_proc
      (
        _start_time=`date +%s`
        $PMEMD -O \
          -i $prefix_input/mdin \
          -p $prefix_input/prmtop \
          -c $prefix_input/restart \
          -ref $prefix_input/inpcrd \
          -r restart \
          -o mdout \
          -x mdcrd

        cp mdout $prefix_bench/output/procs_${n_proc}/time_${i_time}/mdout_${i_proc}

        _end_time=`date +%s`
        _run_time=$((end_time - start_time))
        echo $_run_time > $prefix_bench/output/procs_${n_proc}/time_${i_time}/time_${i_proc}.txt
      ) &
    done
    wait

    end_time=`date +%s`
    run_time=$((end_time - start_time))
    echo $run_time > $prefix_bench/output/procs_${n_proc}/time_${i_time}/time.txt

    rm -rf $FAST_WORKING_DIR/*
  done
done
