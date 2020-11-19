#!/bin/bash

WORLD_SIZE=8

DISTRIBUTED_ARGS="--nproc_per_node $WORLD_SIZE \
                  --nnodes 1 \
                  --node_rank 0 \
                  --master_addr localhost \
                  --master_port 6000"

TRAIN_DATA="data/CNNDM/train.source \
            data/CNNDM/train.target"

VALID_DATA="data/CNNDM/val.source \
            data/CNNDM/val.target"

TEST_DATA="data/CNNDM/test.source \
           data/CNNDM/test.target"

VOCAB_FILE=bert-vocab.txt
PRETRAINED_CHECKPOINT=checkpoints/t5_345m
CHECKPOINT_PATH=checkpoints/t5_345m_cnndm

python -m torch.distributed.launch $DISTRIBUTED_ARGS ./tasks/main_t5.py \
                --task CNNDM \
                --finetune \
                --num-layers 12 \
                --hidden-size 768 \
                --num-attention-heads 12 \
                --kv-channels 64 \
                --ffn-hidden-size 3072 \
                --model-parallel-size 1 \
                --train-data $TRAIN_DATA \
                --valid-data $VALID_DATA \
                --test-data $TEST_DATA \
                --pretrained-checkpoint $PRETRAINED_CHECKPOINT \
                --save-interval 5000 \
                --save $CHECKPOINT_PATH \
                --log-interval 100 \
                --eval-interval 10000 \
                --eval-iters 10 \
                --weight-decay 1.0e-1 \
                --seq-length 512 \
                --decoder-seq-length 512 \
                --vocab-extra-ids 100 \
                --max-position-embeddings 512 \
                --fp16 \
                --vocab-file $VOCAB_FILE \
                --tokenizer-type BertWordPieceLowerCase \
                --epochs 10 \
                --sample-rate 1.0 \
                --batch-size 4 \
                --eval-batch-size 12 \
                --beam-size 1 \
                --max-decode-len 512 \
                --lr 2.0e-5 \
                --warmup 0.0 \
                --lr-decay-style linear
