#!/bin/bash

#########################
# Evaluate the EM scores.
#########################
export CUDA_VISIBLE_DEVICES=4

WORLD_SIZE=1
DISTRIBUTED_ARGS="--nproc_per_node $WORLD_SIZE \
                  --nnodes 1 \
                  --node_rank 0 \
                  --master_addr localhost \
                  --master_port 6004"
                  
MODEL_GEN_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/prompting/predicted/NQ/output_answer_generations_k64_357m_withQAprefix.txt # (e.g., /testseen_knowledge_generations.txt)
GROUND_TRUTH_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/open_domain_data/NQ/test.json #\ (e.g., /testseen_knowledge_reference.txt)

# TQA test set
# MODEL_GEN_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/prompting/predicted/TQA/output_answer_generations_k64_1.3b.txt # (e.g., /testseen_knowledge_generations.txt)
# GROUND_TRUTH_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/open_domain_data/TQA/test.json #\ (e.g., /testseen_knowledge_reference.txt)

# TQA dev set
# MODEL_GEN_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/prompting/predicted/TQA/output_answer_generations_k1_1.3b_dev.txt # (e.g., /testseen_knowledge_generations.txt)
# GROUND_TRUTH_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/open_domain_data/TQA/dev.json #\ (e.g., /testseen_knowledge_reference.txt)

# WebQuestions test set

# MODEL_GEN_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/prompting/predicted/WQ/output_answer_generations_k64_1.3b.txt # (e.g., /testseen_knowledge_generations.txt)
# GROUND_TRUTH_PATH=/gpfs/fs1/projects/gpu_adlr/datasets/dasu/open_domain_data/WQ/WebQuestions-test.txt #\ (e.g., /testseen_knowledge_reference.txt)


python -m torch.distributed.launch $DISTRIBUTED_ARGS ./tasks/odqa/main.py \
        --num-layers 24 \
        --hidden-size 1024 \
        --num-attention-heads 16 \
        --seq-length 2048 \
        --max-position-embeddings 2048 \
        --micro-batch-size 1 \
        --task ODQA-EVAL-EM \
        --guess-file ${MODEL_GEN_PATH} \
        --answer-file ${GROUND_TRUTH_PATH}


############################################
# Evaluate BLEU, METEOR, and ROUGE-L scores.
############################################

# We follow the nlg-eval (https://github.com/Maluuba/nlg-eval) to 
# evaluate the BLEU, METEOR, and ROUGE-L scores. 

# To evaluate on these metrics, please setup the environments based on 
# the nlg-eval github, and run the corresponding evaluation commands.

# nlg-eval \
#     --hypothesis=<PATH_OF_THE_KNOWLEDGE_GENERATION> \
#     --references=<PATH_OF_THE_GROUND_TRUTH_KNOWLEDGE>
