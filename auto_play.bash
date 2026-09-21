python humanoid/scripts/play.py \
  --task=pai_ppo \
  --load_run=Sep21_15-00-20_first_test \
  --checkpoint=200 \
  --num_envs=1 \
  --sim_device=cuda:0 \
  --rl_device=cuda:0 \
  --pipeline=gpu