task SV_cluster_forBP {

    #Inputs and constants defined here

    String pair_id
    String clustering_window
    String alg1
    File forBP1
    String alg2
    File forBP2
    String? alg30
    String alg3 =  select_first([alg30, ""])
    File? forBP30
    String forBP3 =  select_first([forBP30, ""])
    String? alg40
    String alg4 =  select_first([alg40, ""])
    File? forBP40
    String forBP4 =  select_first([forBP40, ""])

    String output_disk_gb = "100"
    String boot_disk_gb = "10"
    String ram_gb = "2"
    String cpu_cores = "1"
    String preemption = "4"


    command {
cat <<EOF > pyscript.py

import subprocess,os
def run(cmd):
    print('about to run')
    print(cmd)
    print('')
    subprocess.check_call(cmd,shell=True)

run('ln -sT `pwd` /opt/execution')
run('ln -sT `pwd`/../inputs /opt/inputs')
run('/opt/src/algutil/monitor_start.py')

# start task-specific calls
##########################



cwd = os.getcwd()

pair_id = '${pair_id}'
clustering_window = '${clustering_window}'
alg1='${alg1}'
forBP1='${forBP1}'
alg2='${alg2}'
forBP2='${forBP2}'
alg3='${alg3}'
forBP3='${forBP3}'
alg4='${alg4}'
forBP4='${forBP4}'

run('ls -latr ')

cmd = 'python /opt/src/algutil/firehose_module_adaptor/run_module.py --module_libdir /opt/src/SV_cluster_forBP \
--pair_id %s \
--clustering.window %s \
--alg1 %s \
--forBP1 %s \
--alg2 %s \
--forBP2 %s \
--alg3 %s \
--forBP3 %s \
--alg4 %s \
--forBP4 %s '% (pair_id, clustering_window,alg1,forBP1,alg2,forBP2,alg3,forBP3,alg4,forBP4)

run(cmd)

run('ls -latr ')

import time
#time.sleep(999999999)


#########################
# end task-specific calls
run('/opt/src/algutil/monitor_stop.py')
EOF

        cat pyscript.py 
        python pyscript.py

    }

    output {
        File consensus_forBP_txt="${PAIRID}.${alg1}.${alg2}.${alg3}.${alg4}.forBP.txt"
        File consensus_forBP_mat="${PAIRID}.${alg1}.${alg2}.${alg3}.${alg4}.forBP.mat"
        File dstat_log="dstat.log"
    }

    runtime {
        docker : "docker.io/chipstewart/sv_cluster_forbp:1"
        memory: "${ram_gb}GB"
        cpu: "${cpu_cores}"
        disks: "local-disk ${output_disk_gb} HDD"
        bootDiskSizeGb: "${boot_disk_gb}"
        preemptible: "${preemption}"
    }


    meta {
        author : "Chip Stewart"
        email : "stewart@broadinstitute.org"
    }

}

workflow SV_cluster_forBP_workflow {
    call SV_cluster_forBP
}

