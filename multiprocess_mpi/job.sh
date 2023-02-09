#!/bin/bash -eux
#PBS -l select=1:ncpus=16:ompthreads=1:mpiprocs=8:ngpus=1
#PBS -l walltime=12:00:00

prefix=$PREFIX_BENCHMARK_HPC
prefix_input=$prefix/input_data
prefix_bench=$prefix/multiprocess_mpi
FAST_WORKING_DIR=/lwork/users/$USER/$PBS_JOBID
PMEMD=pmemd.cuda.MPI

# Input ----------

n_times=1
n_procs=4

echo "select=1:ncpus=16:ompthreads=1:mpiprocs=8:ngpus=1"

# ----------------

module purge
module load amber/22u1

# Copy input files
cd $FAST_WORKING_DIR
cp $prefix_input/* .

# Create groupfile
for i in `seq 1 ${n_procs}`;do
  echo $i
  sed "s/IPROC/${i}/g" $prefix/multiprocess_mpi/groupfile.ref >> groupfile
done
echo "" >> groupfile

for i_time in `seq 1 ${n_times}`;do
  mkdir -p $prefix_bench/output/procs_${n_procs}/time_${i_time}
  start_time=`date +%s`

  mpirun -np $((($n_procs)*2)) \
    $PMEMD -O \
    -ng $n_procs \
    -rem 0 \
    -groupfile groupfile

  cp mdout_* $prefix_bench/output/procs_${n_procs}/time_${i_time}/

  end_time=`date +%s`
  run_time=$((end_time - start_time))
  echo $run_time > $prefix_bench/output/procs_${n_procs}/time_${i_time}/time.txt
done
