extends Node

# 背景・地面・パイプが左へ流れる速さ（px/秒）
const SCROLL_SPEED := 350.0

# 上下のパイプのすき間の高さ
const PIPE_GAP_SIZE := 300.0
# すき間の中心を、画面の上端と地面からどれだけ離すか
const PIPE_GAP_MARGIN := PIPE_GAP_SIZE
# パイプを出す間隔（秒）。パイプ同士の距離は SCROLL_SPEED * この値になる
const PIPE_SPAWN_INTERVAL := 2.0
