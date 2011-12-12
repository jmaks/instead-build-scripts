FL_PATH = 0x80
COLORS_NR = 7
BONUSES_NR = 4
BONUS_PCNT = 5
ball1 = 1
ball2 = 2
ball3 = 3
ball4 = 4
ball5 = 5
ball6 = 6
ball7 = 7
ball_joker = 8
ball_bomb = 9
ball_brush = 10
ball_boom = 11
ball_max = 12

IDLE=0
MOVING=1
FILL_POOL=2
FILL_BOARD=3
CHECK=4
REMOVE=5
END=6

BOARD_W=9
BOARD_H=9
POOL_SIZE=3
BALLS_ROW=5

global {
	board = {};
	ball_pool = {};
}

move_matrix = {};
move_matrix_ids = {};

ball_x = 0
ball_y = 0
ball_to_x = 0;
ball_to_y = 0;

board_state = IDLE
flushes = {}
function cell_get(x, y)
	if x < 0 or x >= BOARD_W then
		return 0
	end
	if y < 0 or y >= BOARD_H then
		return 0
	end
	return board[x + 1][y + 1];
end

board_cell = cell_get

function cell_set(x, y, c)
	if x < 0 or x >= BOARD_W then
		return
	end
	if y < 0 or y >= BOARD_H then
		return
	end
	board[x + 1][y + 1] = c;
end

function board_selected()
	local c = cell_get(ball_x, ball_y);
	if c == 0 then
		return
	end
	return ball_x, ball_y
end

function board_moved()
	if ball_to_x == -1 or ball_to_y == -1 or board_state ~= CHECK then
		return
	end
	return ball_to_x, ball_to_y
end

function get_rand_cell()
	local r = rnd(100)  - 1;
	if r < BONUS_PCNT then
		return ball_joker + rnd(BONUSES_NR) - 1;
	end
	return rnd(COLORS_NR)
end

function get_rand_color()
	return rnd(7)
end

function board_fill_pool()
	local i
	for i=1,POOL_SIZE do
		ball_pool[i] = get_rand_cell()
	end
	pool_ball = 0
end

global {
	score = 0;
	score_mul = 1;
	free_cells = BOARD_W * BOARD_H;
}

function board_init()
	local x,y
	score = 0
	score_mul = 1
	flush_nr = 0
	free_cells = BOARD_W * BOARD_H

	for x=1,BOARD_W do
		board[x] = { }
		flushes[x] = {}
		move_matrix[x] = {}
		move_matrix_ids[x] = {}
		for y=1,BOARD_H do
			board[x][y] = 0
			move_matrix[x][y] = 0
			move_matrix_ids[x][y] = 0
			flushes[x][y] = {}
		end
	end
	for x=1,POOL_SIZE do
		ball_pool[x] = 0
	end
	for x=1,POOL_SIZE do
		ball_pool[x] = 0
	end

	ball_x = -1
	ball_y = -1
	ball_to_x = -1
	ball_to_y = -1
	board_fill_pool()
	board_fill()
	board_fill()
	board_fill()
	board_fill_pool()
	board_state = IDLE
end

function find_pos(pos)
	local x,y
	for y=1,BOARD_H do
		for x=1,BOARD_W do
			local c = cell_get(x - 1, y - 1);
			if c == 0 then
				if pos == 0 then
					return x - 1, y - 1
				end
				pos = pos - 1
			end
		end
	end
end

function board_fill()
	if free_cells < 1 then
		return -1
	end
	local pos = rnd(free_cells) - 1;
	local x,y = find_pos(pos);
	if not x then
		error "Panic error!"
	end
	local ncell = ball_pool[pool_ball + 1];
	cell_set(x, y, ncell);
	free_cells = free_cells - 1
	pool_ball = pool_ball + 1
--	print("fill x, y, c", x, y, ncell)
	return POOL_SIZE - pool_ball, x, y;
end

function pool_cell(x)
	local c = 0
	if x >= POOL_SIZE then
		return 0
	end
	if x < pool_ball then
		c = 0
	else
		c = ball_pool[x + 1];
	end
	return c
end

function mark_cell(x, y, n, id)
	local new
	if n == 0 then
		return 0
	end
	if x < 0 or x >= BOARD_W then
		return 0
	end
	if y < 0 or y >= BOARD_H then
		return 0
	end
	if cell_get(x, y) ~= 0 then
		return 0
	end
	if move_matrix[x + 1][y + 1] >= FL_PATH then
		return 0
	end
	new = n + 1
	if move_matrix[x + 1][y + 1] == 0 or move_matrix[x + 1][y + 1] > new then
		move_matrix_ids[x + 1][y + 1] = id
		move_matrix[x + 1][y + 1] = new
	else
		return 0
	end
	return new
end

function move_cell(x, y, n, id)
	if x < 0 or x >= BOARD_W then
		return 0
	end

	if y < 0 or y >= BOARD_H then
		return 0
	end
	
	if move_matrix_ids[x + 1][y + 1] ~= id then
		return 0
	end
	return move_matrix[x + 1][y + 1]
end
function mark_fl(x, y)
	local v = move_matrix[x + 1][y + 1]
	if v >= FL_PATH then
		return
	end
	move_matrix[x + 1][y + 1] = move_matrix[x + 1][y + 1] + FL_PATH
end

function normalize_move_matrix(x, y, tox, toy, id)
	local dx, dy, i
	local last_move = -1
	local num = move_matrix[x + 1][y + 1]
	mark_fl(x, y)
	repeat
		local w = {   {x = 0, y = 0, n = 0}, 
				{x = 0, y = 0, n = 0}, 
				{x = 0, y = 0, n = 0}, 
				{x = 0, y = 0, n = 0} };
		local ways = { 0, 1, 2, 3 };
		w[1].x = x + 1; w[2].x  = x; w[3].x = x - 1; w[4].x = x;
		w[1].y = y; w[2].y = y + 1; w[3].y = y; w[4].y = y - 1;

		w[1].n = move_cell(x + 1, y, num, id);
		w[2].n = move_cell(x, y + 1, num, id);
		w[3].n = move_cell(x - 1, y, num, id);
		w[4].n = move_cell(x, y - 1, num, id);

		dx = tox - x;
		dy = toy - y;
		
		if math.abs(dx) > math.abs(dy) then
			if dy > 0 then
				ways[1] = 1
				ways[2] = 3
			else
				ways[1] = 3
				ways[2] = 1
			end
			if dx > 0 then
				ways[3] = 0
				ways[4] = 2
			else
				ways[3] = 2
				ways[4] = 0
			end
		else
			if dx > 0 then
				ways[1] = 0
				ways[2] = 2
			else
				ways[1] = 2
				ways[2] = 0
			end
			if dy > 0 then
				ways[3] = 1
				ways[4] = 3
			else
				ways[3] = 3
				ways[4] = 1
			end
		end
		
		if last_move == -1 or w[last_move + 1].n ~= num - 1 then
			for i=1, 4 do
				if w[ways[i] + 1].n == num - 1 then
					last_move = ways[i]
					break
				end
			end
		end
		
		num = w[last_move + 1].n
		x = w[last_move + 1].x
		y = w[last_move + 1].y
		mark_fl(x, y);
	until num == 1
end

function board_path(x, y)
	if x < 0 or x >= BOARD_W then
		return 0
	end
	
	if y < 0 or y >= BOARD_H then
		return 0
	end
	
	if move_matrix[x + 1][y + 1] >= FL_PATH then
		return 1
	end	
	return 0
end

function board_clear_path(x, y)
	if move_matrix[x + 1][y + 1] < FL_PATH then
		return
	end
	move_matrix[x + 1][y + 1] = move_matrix[x + 1][y + 1] - FL_PATH
end

function board_follow_path(x, y, id)
	local num, a, v
	num = move_matrix[x + 1][y + 1];
	if num < FL_PATH then
		return
	end
	num = num - FL_PATH
	
	a = move_cell(x + 1, y, num, id)
	
	v = a; if v >= FL_PATH then v = v - FL_PATH end
	
	if a >= FL_PATH and v == num + 1 then
		return x + 1, y
	end
	
	a = move_cell(x, y + 1, num, id);
	
	v = a; if v >= FL_PATH then v = v - FL_PATH end
	
	if a >= FL_PATH and v == num + 1 then
		return x, y + 1
	end

	a = move_cell(x - 1, y, num, id);
	
	v = a; if v >= FL_PATH then v = v - FL_PATH end
	
	if a >= FL_PATH and v == num + 1 then
		return x - 1, y
	end

	a = move_cell(x, y - 1, num, id);
	
	v = a; if v >= FL_PATH then v = v - FL_PATH end
	
	if a >= FL_PATH and v == num + 1 then
		return x, y - 1
	end
	return x, y
end

function board_move(x1, y1, x2, y2)
	local x, y, mark = 1
	local id = x1 + y1 * BOARD_W
--	print ("path: ", x1, y1, x2, y2)
	for y=1, BOARD_H do
		for x = 1, BOARD_W do
			if move_matrix[x][y] < FL_PATH then
				move_matrix[x][y] = 0
				move_matrix_ids[x][y] = -1
			end
		end
	end
	if move_matrix[x1 + 1][y1 + 1] ~= 0 then
		return 0
	end
	move_matrix[x1 + 1][y1 + 1] = 1
	move_matrix_ids[x1 + 1][y1 + 1] = id
	while mark ~= 0 do
		mark = 0
		for y = 1, BOARD_H do
			for x = 1, BOARD_W do
				if move_matrix[x][y] ~= 0 and board_path(x - 1, y - 1) == 0 then
					mark = mark + mark_cell(x - 1 - 1, y - 1, move_matrix[x][y], id);
					mark = mark + mark_cell(x + 1 - 1, y - 1, move_matrix[x][y], id);
					mark = mark + mark_cell(x - 1, y - 1 - 1, move_matrix[x][y], id);
					mark = mark + mark_cell(x - 1, y + 1 - 1, move_matrix[x][y], id);
				end
			end
		end
	end
	if board_path(x2, y2) == 0 and move_matrix[x2 + 1][y2 + 1] ~= 0 then
		local c = cell_get(x1, y1);
		cell_set(x1, y1, 0)
		cell_set(x2, y2, c)
		normalize_move_matrix(x2, y2, x1, y1, id)
--		print ("to, ", x2, y2)
		return 1
	end
	return 0 
end

function is_color(c)
	if c == 0 then
		return 0
	end
	if c <= 7 then
		return 1
	end
	return 0
end

function is_joker(c)
	if c == ball_joker or c == ball_bomb then
		return 1
	end
	return 0
end

function joinable(c, d)
	local rc = d
	if c == 0 or d == 0 then return 0 end
	if is_joker(d) ~= 0 then 
		rc = c
	end
	if c == rc then 
		return rc
	end
	if is_joker(c) ~= 0 then 
		return rc
	end
	return 0
end

function flush_add(x1, y1, x2, y2, col)
	local f = {}
--	print ("flush_add", col)
	if x2 > x1 then
		x2 = x2 + 1
	end
	if y2 > y1 then
		y2 = y2 + 1
	end
	if y2 < y1 then
		y2 = y2 - 1
	end
	f.nr = 0
	f.col = col
	f.bomb = 0
	f.cells = {}
	repeat
		if cell_get(x1, y1) == ball_bomb then
			f.bomb = f.bomb + 1
		end
		f.cells[f.nr + 1] = {}
		f.cells[f.nr + 1].x = x1
		f.cells[f.nr + 1].y = y1
		f.nr = f.nr + 1
		if x1 < x2 then
			x1 = x1 + 1
		end
		if y1 < y2 then
			y1 = y1 + 1
		elseif y1 > y2 then
			y1 = y1 - 1
		end
	until x1 == x2 and y1 == y2
	flushes[flush_nr + 1] = f
--	print ("added flush", f.nr)
	flush_nr = flush_nr + 1
end

function remove_cell(x, y)
	local c = cell_get(x, y)
	local rc = 0
	if  c == 0 then return 0 end
	if is_color(c) ~= 0 or is_joker(c) ~= 0 then
		score_delta = score_delta + 1
		rc = rc + 1
	end
	if c == ball_joker then
		score_mul = score_mul * 2
	end
	cell_set(x, y, 0);
	free_cells = free_cells + 1
	return rc
end

function remove_color(col)
	local x,y
--	print ("remove color", col)
	for y=1,BOARD_H do
		for x=1,BOARD_W do
			local c = cell_get(x - 1, y - 1)
			if c == col then
				remove_cell(x - 1, y - 1)
			end
		end
	end
	return 0
end

function flushes_remove()
	local i,k
	for i=1, flush_nr do
		local c,f
		f = flushes[i];
		for k=1, f.nr do
			if f.bomb ~= 0 then
				remove_color(f.col)
			end
			c = cell_get(f.cells[k].x, f.cells[k].y)
			if c ~= 0 then
				remove_cell(f.cells[k].x, f.cells[k].y)
			end
		end
	end
	if flush_nr ~= 0 then
		flush_nr = 0
		return 1
	end
	return 0
end

function scan_hline(x, y)
	local xi, yi, b
	while x < BOARD_W and cell_get(x, y) == 0 do
		x = x + 1
	end
	if BOARD_W - x < BALLS_ROW then
		return BOARD_W
	end
	b = cell_get(x, y)
	xi = x; yi = y
	while xi < BOARD_W do
		local ob = b
		b = joinable(cell_get(xi, yi), b)
		if b == 0 then b = ob break end
		xi = xi + 1
	end
	if xi - x >= BALLS_ROW then
		flush_add(x, y, xi - 1, y, b);
	end
	if is_joker(b) ~= 0 then
		return xi
	end
	while is_joker(cell_get(xi - 1, yi)) ~= 0 do
		xi = xi - 1
	end
	return xi
end

function scan_vline(x, y)
	local xi,yi,b
	while y < BOARD_H and cell_get(x, y) == 0 do
		y = y + 1
	end
	b = cell_get(x, y)
	xi = x; yi = y
	while yi < BOARD_H do
		local ob = b
		b = joinable(cell_get(xi, yi), b)
		if b == 0 then b = ob break end
		yi = yi + 1
	end
	if yi - y >= BALLS_ROW then
		flush_add(x, y, xi, yi - 1, b)
	end
	if is_joker(b) ~= 0 then
		return yi
	end
	while is_joker(cell_get(xi, yi - 1)) ~= 0 do
		yi = yi - 1
	end
	return yi
end

function scan_aline(x, y)
	local xi, yi, b
	while x < BOARD_W and y >= 0 and cell_get(x, y) == 0 do
		y = y - 1
		x = x + 1
	end
	b = cell_get(x, y)
	xi = x; yi = y
	while xi < BOARD_W and yi >= 0 do
		local ob = b
		b = joinable(cell_get(xi, yi), b)
		if b == 0 then b = ob break end
		yi = yi - 1
		xi = xi + 1
	end
	if xi - x >= BALLS_ROW then
--		print "flish added"
		flush_add(x, y, xi - 1, yi + 1, b);
	end
	if is_joker(b) ~= 0 then
		return xi
	end
	while is_joker(cell_get(xi - 1, yi + 1)) ~= 0 do
		yi = yi + 1
		xi = xi - 1
	end
	return xi
end

function scan_bline(x, y)
	local xi, yi, b
	while x < BOARD_W and y < BOARD_H and cell_get(x, y) == 0 do
		y = y + 1
		x = x + 1
	end
	b = cell_get(x, y)
	xi = x; yi = y
	while xi < BOARD_W and yi < BOARD_H do
		local ob = b
		b = joinable(cell_get(xi, yi), b)
		if b == 0 then b = ob break end
		yi = yi + 1
		xi = xi + 1
	end
	if xi - x >= BALLS_ROW then
		flush_add(x, y, xi - 1, yi - 1, b);
	end

	if is_joker(b) ~= 0 then
		return xi
	end
	while is_joker(cell_get(xi - 1, yi - 1)) ~= 0 do
		yi = yi - 1
		xi = xi - 1
	end
	return xi
end

function board_check_hlines()
	local x,y
	local of = flush_nr
	for y=1, BOARD_H do
		for x = 1, BOARD_W do
			x = scan_hline(x - 1, y - 1) + 1
		end
	end
	return flush_nr - of
end

function board_check_vlines()
	local x,y
	local of = flush_nr

	for x=1, BOARD_W do
		for y = 1, BOARD_H do
			y = scan_vline(x - 1, y - 1) + 1
		end
	end
	return flush_nr - of
end

function board_check_alines()
	local x, y
	local of = flush_nr
	for y = 1, BOARD_H do
		for x = 1, y do
			x = scan_aline(x - 1, y - x) + 1
		end
	end
	for y = 1, BOARD_W do
		for x = y, BOARD_W do
			x = scan_aline(x - 1, BOARD_H - 1 - (x - y)) + 1
		end
	end
	return flush_nr - of
end

function board_check_blines()
	local x, y
	local of = flush_nr
	for y = 1, BOARD_W do
		for x = y, BOARD_W do
			x = scan_bline(x - 1, x - y) + 1
		end
	end
	for y = 1, BOARD_H do
		for x = 0, BOARD_W - y do
			x = scan_bline(x - 1, y + x - 1) + 1
		end
	end
	return flush_nr - of
end

function boom_ball(x, y)
	local rc = 0
	local c = cell_get(x, y)
	if c == 0 then
		return 0
	end
	if c == ball_boom then
		rc = rc + board_boom(x, y);
	elseif c ~= 0 then
		rc = rc + remove_cell(x, y)
	end
	return rc
end

function board_boom(x, y)
	local rc = 0
	local c = cell_get(x, y)
	if c == ball_boom then
		cell_set(x, y, 0);
		free_cells = free_cells + 1
		c = cell_get(x - 1, y)
		if c ~= 0 then
			rc = rc + boom_ball(x - 1, y);
		end

		c = cell_get(x + 1, y)
		if c ~= 0 then
			rc = rc + boom_ball(x + 1, y);
		end

		c = cell_get(x, y - 1)
		if c ~= 0 then
			rc = rc + boom_ball(x, y - 1);
		end

		c = cell_get(x, y + 1)
		if c ~= 0 then
			rc = rc + boom_ball(x, y + 1);
		end

		c = cell_get(x + 1, y - 1)
		if c ~= 0 then
			rc = rc + boom_ball(x + 1, y - 1);
		end

		c = cell_get(x - 1, y - 1)
		if c ~= 0 then
			rc = rc + boom_ball(x - 1, y - 1);
		end

		c = cell_get(x + 1, y + 1)
		if c ~= 0 then
			rc = rc + boom_ball(x + 1, y + 1);
		end

		c = cell_get(x - 1, y + 1)
		if c ~= 0 then
			rc = rc + boom_ball(x - 1, y + 1);
		end
		return rc
	end
	return 0
end

function board_paint(x, y)
	local rc = 0
	local col = get_rand_color();
	local c = cell_get(x, y);
	if c == ball_brush then
		cell_set(x, y, 0);
		free_cells = free_cells + 1
		c = cell_get(x - 1, y);
		if is_color(c) ~= 0 then
			cell_set(x - 1, y, col);
			rc = rc + 1
		end

		c = cell_get(x + 1, y);
		if is_color(c) ~= 0 then
			cell_set(x + 1, y, col);
			rc = rc + 1
		end

		c = cell_get(x, y - 1);
		if is_color(c) ~= 0 then
			cell_set(x, y - 1, col);
			rc = rc + 1
		end

		c = cell_get(x, y + 1);
		if is_color(c) ~= 0 then
			cell_set(x, y + 1, col);
			rc = rc + 1
		end

		c = cell_get(x + 1, y - 1);
		if is_color(c) ~= 0 then
			cell_set(x + 1, y - 1, col);
			rc = rc + 1
		end

		c = cell_get(x - 1, y - 1);
		if is_color(c) ~= 0 then
			cell_set(x - 1, y - 1, col);
			rc = rc + 1
		end

		c = cell_get(x + 1, y + 1);
		if is_color(c) ~= 0 then
			cell_set(x + 1, y + 1, col);
			rc = rc + 1
		end

		c = cell_get(x - 1, y + 1);
		if is_color(c) ~= 0 then
			cell_set(x - 1, y + 1, col);
			rc = rc + 1
		end
		return rc
	end
	return 0
end

function board_check(x, y)
	local rc = 0
 	rc = board_paint(x, y)
	rc = rc + board_boom(x, y)
	return rc + board_check_hlines() + board_check_vlines() + board_check_alines() + board_check_blines();
end

function board_select(x, y)
	local c
	if x == -1 and y == -1 then
		ball_x = -1
		ball_y = -1
		return 0
	end
	if x < 0 or x >= BOARD_W then
		return 0
	end
	if y < 0 or y >= BOARD_H then
		return 0
	end
	c = cell_get(x, y)
	if c ~= 0 then
		ball_x = x
		ball_y = y
		return 0
	end
	if cell_get(ball_x, ball_y) == 0 then
		return 0
	end
	if board_state ~= IDLE then
		return 0
	end
	ball_to_x = x
	ball_to_y = y
	board_state = MOVING
--	print("select", ball_x, ball_y, ball_to_x, ball_to_y);
--	print ("board_state = ", board_state);
	return 1
end
check_rc = 0
check_x = 0
check_y = 0
function board_logic()
	local fl
--	print ("board_state = ", board_state)
	if board_state == IDLE then
		if free_cells <= 0 then
			board_state = END
		elseif free_cells == BOARD_W * BOARD_H then
			board_state = FILL_BOARD
		end
	elseif board_state == MOVING then
		if board_move(ball_x, ball_y, ball_to_x, ball_to_y) == 0 then
			board_state = IDLE
		else
			board_state = CHECK
			check_rc = -1
			ball_x = -1
			ball_y = -1
		end
	elseif board_state == FILL_POOL then
		board_fill_pool()
		if free_cells == BOARD_W * BOARD_H then
			board_state = FILL_BOARD
		else
			board_state = IDLE
		end
	elseif board_state == FILL_BOARD then
		check_rc, check_x, check_y = board_fill()
		if check_rc < 0 then
			board_state = END
		else
			board_state = CHECK
		end
	elseif board_state == CHECK then
		score_delta = 0
		if check_rc == -1 then
			check_x = ball_to_x
			check_y = ball_to_y
		else
			check_x = -1
			check_y = -1
		end
		ball_to_x = -1
		ball_to_y = -1
		if board_check(check_x, check_y) ~= 0 then
--			print "remove"
			board_state = REMOVE
		elseif check_rc ~= -1 then
			if POOL_SIZE - pool_ball > 0 then
				board_state = FILL_BOARD
			else
				board_state = FILL_POOL
			end
		else
			board_state = FILL_BOARD
			score_mul = 1
		end
	elseif board_state == REMOVE then
		fl = flushes_remove()
		score = score + score_delta * score_mul;
		if fl ~= 0 then
			score_mul = score_mul + 1
		end
		if check_rc ~= - 1 then
			if POOL_SIZE - pool_ball > 0 then
				board_state = FILL_BOARD
			else
				board_state = FILL_POOL
			end
		else
			board_state = IDLE
		end
	end	
	return 0
end

function board_score()
	return score
end

function board_score_mul()
	return score_mul - 1
end

function board_running()
	if board_state == END then
		return 0
	end
	return 1
end
