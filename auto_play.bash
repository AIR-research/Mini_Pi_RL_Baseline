python humanoid/scripts/play.py \
  --task=pai_ppo \
  --load_run=Sep21_15-00-20_first_test \
  --checkpoint=100 \
  --num_envs=1 \
  --sim_device=cpu \
  --rl_device=cpu \
  --pipeline=cpu
