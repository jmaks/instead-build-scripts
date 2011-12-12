HISCORES_NR = 5
BONUS_BLINKS = 4
BONUS_TIMER = 40 
ALPHA_STEPS = 12 -- 16
SIZE_STEPS = 12 -- 16
JUMP_STEPS = 6 -- 8
JUMP_MAX = 0.8
BALL_STEP = 25
TILE_WIDTH = 50
TILE_HEIGHT = 50

BOARD_WIDTH = (BOARD_W * TILE_WIDTH)
BOARD_HEIGHT = (BOARD_H * TILE_HEIGHT)

BOARD_X = 800 - 450 - 15
BOARD_Y = 15
SPECIAL_BALLS = 4
BALL_JOKER = 8
BALL_BOMB = 9
BALL_BRUSH = 10
BALLS_NR = 7

POOL_SPACE = 8

SCORES_X = 60
SCORES_Y = 208
SCORES_W = (BOARD_X - TILE_WIDTH - SCORES_X - 40)
SCORE_X	= 0
SCORE_Y	= 175
SCORE_W	= (BOARD_X - 23)

fadein = 1
fadeout = 2
changing = 3
jumping = 4
moving = 5

moving_nr = 0

balls = {}
resized_balls = {}
jumping_balls = {}

function gfx_ball_new()
	local v = { 
		used = 0;
		draw_needed = 0;
		x = 0;
		y = 0;
		tx = 0;
		ty = 0;
		effect = 0;
		step = 0;
		id = 0;
		cell = 0;
		cell_from = 0;
	}
	return v
end

game_board = {};
game_pool = {};

function game_init()
	local x, y
	for x=1,BOARD_W do
		game_board[x] = {}
		for y=1,BOARD_H do
			game_board[x][y] = gfx_ball_new()
		end
	end
	for x=1,POOL_SIZE do
			game_pool[x] = gfx_ball_new()
	end
end

function enable_effect(x, y, effect)
	local b
	if x == -1 then
		b = game_pool[y + 1];
	else
		b = game_board[x + 1][y + 1];
	end
	b.x = x
	b.y = y
	b.used = 1
	b.draw_needed = 1
	b.effect = effect
	b.step = 0
end

function disable_effect(x, y, effect)
	local b
	if x == -1 then
		b = game_pool[y + 1];
	else
		b = game_board[x + 1][y + 1];
	end
	b.draw_needed = 1
	b.effect = 0
end

function game_move_ball()
	local tx, ty = board_moved()
	
	local x, y  = board_selected()

	if x then
		selected_x, selected_y = x, y
	end
--	print ("move: ", x, y, tx, ty, board_state)
	if not tx and not x then
		return 0
	end

	if x and game_board[x + 1][y + 1].effect == 0 
		and game_board[x + 1][y + 1].cell ~= 0 and game_board[x + 1][y + 1].used ~= 0 then
			enable_effect(x, y, jumping);
			game_board[x + 1][y + 1].step = 0;
	end

	x, y = selected_x, selected_y

	if tx and game_board[tx + 1][ty + 1].cell == 0 then
		moving_nr = moving_nr + 1
		game_board[tx + 1][ty + 1].used = 0
		game_board[tx + 1][ty + 1].cell = game_board[x + 1][y + 1].cell
		enable_effect(tx, ty, moving);
		game_board[tx + 1][ty + 1].tx = tx
		game_board[tx + 1][ty + 1].ty = ty
		game_board[tx + 1][ty + 1].id = y * BOARD_W + x
		game_board[tx + 1][ty + 1].x = x
		game_board[tx + 1][ty + 1].y = y
		disable_effect(x, y);
		game_board[x + 1][y + 1].draw_needed = 0
		game_board[x + 1][y + 1].used = 0
		game_board[x + 1][y + 1].cell = 0
	end
	return 1
end

function game_process_pool()
	local rc = 0
	local x
	for x = 1, POOL_SIZE do
		local b = game_pool[x]
		local c = pool_cell(x - 1);
		if c ~= 0 and b.cell == 0 and b.effect == 0 then
			enable_effect(-1, x - 1, fadein);
			b.cell = c
			rc = rc + 1
		elseif c == 0 and b.cell ~= 0 and b.effect == 0 then
			enable_effect(-1, x - 1, fadeout)
			rc = rc + 1
		end
	end
	return rc
end

function game_process_board()
	local fadeout_nr = 0
	local paint_nr = 0
	local boom_nr = 0
	local x, y
	local rc = 0
	for y = 1, BOARD_H do
		for x = 1, BOARD_W do
			local b = game_board[x][y]
			local c = board_cell(x - 1, y - 1);
			if c ~= 0 and b.cell == 0 and b.effect == 0 then
				enable_effect(x - 1, y - 1, fadein);
				b.cell = c
				rc = rc + 1
			elseif c ~= 0 and b.cell ~= 0 and c ~= b.cell and b.effect == 0 then
				enable_effect(x - 1, y - 1, changing);
				b.cell_from = b.cell
				b.cell = c
				rc = rc + 1
			elseif c == 0 and b.cell ~= 0 and (b.effect == 0 or b.effect == jumping) then
				if b.cell == ball_boom then
					boom_nr = boom_nr + 1
				elseif b.cell == ball_brush then
					paint_nr = paint_nr + 1
				else
					fadeout_nr = fadeout_nr + 1
				end
				enable_effect(x - 1, y - 1, fadeout);
				rc = rc + 1
			end
		end
	end
	-- todo sounds
	if boom_nr ~= 0 then
		sound.play (boom_snd)
	end
	if paint_nr ~= 0 then
		sound.play (paint_snd);
	end
	if fadeout_nr ~= 0 then
		sound.play (fadeout_snd);
	end
	return rc
end

function game_display_board()
	local x, y, tmpx, tmpy, x1, y1, dx, dy, dist
	local rc = 0
	local drawn = 0
	for y = 1, BOARD_H do
		for x = 1, BOARD_W do
			local b = game_board[x][y]
			if b.draw_needed ~= 0 then
				drawn = drawn + 1
				rc = rc + 1
				if b.effect == 0 then
					rc = rc -1
					draw_cell(x - 1, y - 1);
					if b.used ~= 0 then
						draw_ball(b.cell - 1, x - 1, y - 1);
					else
						b.cell = 0
					end
					b.draw_needed = 0
				elseif b.effect == fadein then
					rc = rc - 1
					if board_path(b.x, b.y) == 0 then
						draw_cell(b.x, b.y);
						draw_ball_size(b.cell - 1, b.x, b.y, b.step);
						b.step = b.step + 1
						if b.step >= SIZE_STEPS then
							disable_effect(x - 1, y - 1);
						end
					end
				elseif b.effect == jumping then
					rc = rc - 1
					draw_cell(b.x, b.y)
					dist = b.step % (3 * JUMP_STEPS)
					if dist < JUMP_STEPS then
						draw_ball_jump(b.cell - 1, b.x, b.y, dist);
					elseif dist >= JUMP_STEPS and dist < 2*JUMP_STEPS then
						draw_ball_jump(b.cell - 1, b.x, b.y, 2*JUMP_STEPS - dist - 1)
					elseif dist < 2*JUMP_STEPS + 5 and dist >= 2*JUMP_STEPS then
						draw_ball_offset(b.cell - 1, b.x, b.y, 0, 2*JUMP_STEPS - dist);
					elseif dist < 2*JUMP_STEPS + 10 and dist >= 2*JUMP_STEPS + 5 then
						draw_ball_offset(b.cell - 1, b.x, b.y, 0, dist - 2*JUMP_STEPS - 10);
					end
					b.step = b.step + 1;
					tmpx, tmpy = board_selected()
					if dist == 2 * JUMP_STEPS and ( not tmpx or tmpx ~= b.x or tmpy ~= b.y ) then
						disable_effect(x - 1, y - 1);
					elseif b.step >= 3*JUMP_STEPS * 19 + 2*JUMP_STEPS then
						disable_effect(x - 1, y - 1);
						board_select(-1, -1);
					end
				elseif b.effect == moving then
					x1 = b.x;
					y1 = b.y;
--					draw_cell(b.x, b.y);
					tmpx, tmpy = board_follow_path(b.x, b.y, b.id);

					if not tmpx then
						error "Fatal: moving"
					end
					draw_cell(x1, y1, tmpx, tmpy);
					dist = math.abs(b.tx - b.x) + math.abs(b.ty - b.y);
					if dist <= 2 then
						local d = math.floor (BALL_STEP * (TILE_WIDTH * dist - b.step)) / (TILE_WIDTH + TILE_WIDTH);
 						if d <= 3 then d = 2 end
						b.step = b.step + d;
					else
						b.step = b.step + BALL_STEP;
					end

					dx = (tmpx - b.x) * b.step;
					dy = (tmpy - b.y) * b.step;
					if math.abs(dx) >= TILE_WIDTH or math.abs(dy) >= TILE_HEIGHT then
--						print "cleear"
						board_clear_path(b.x, b.y);
						b.x = tmpx;
						b.y = tmpy;
						dx = 0;
						dy = 0;
						b.step = 0;
					end
					draw_ball_offset(b.cell - 1, b.x, b.y, dx, dy); 
					if b.x == b.tx and b.y == b.ty then
						moving_nr = moving_nr - 1;
						board_clear_path(b.x, b.y);
						b.draw_needed = 1;
						b.effect = 0;
						b.used = 1;
					end
				elseif b.effect == changing then
					draw_cell(b.x, b.y);
					draw_ball_alpha(b.cell_from - 1, b.x, b.y, 
						ALPHA_STEPS - b.step - 1); 
					draw_ball_alpha(b.cell - 1, b.x, b.y, b.step); 
					b.step = b.step + 1;
					if b.step >= ALPHA_STEPS - 1 then
						disable_effect(x - 1, y - 1);
					end
				elseif b.effect == fadeout then
					draw_cell(b.x, b.y);
					draw_ball_alpha(b.cell - 1, b.x, b.y, ALPHA_STEPS - b.step - 1); 
					b.step = b.step + 1;
					if b.step == ALPHA_STEPS then
						disable_effect(x - 1, y - 1);
						b.used = 0;
						b.cell = 0;
					end
				end
			end
		end
	end
	return rc, drawn
end
function game_display_pool()
	local x
	local rc = 0
	for x = 1, POOL_SIZE do
		local b = game_pool[x]
		if b.draw_needed ~= 0 then
			rc = rc + 1
			if b.effect == 0 then
				rc = rc - 1
				draw_cell(-1, x - 1)
				if b.used ~= 0 then
					draw_ball(b.cell - 1, -1, x - 1)
				else
					b.cell = 0
				end
				b.draw_needed = 0
			elseif b.effect == fadein then
				draw_cell(-1, b.y)
				draw_ball_size(b.cell - 1, -1, b.y, b.step)
				b.step = b.step + 1
				if b.step >= SIZE_STEPS then
					disable_effect(-1, x - 1)
				end
			elseif b.effect == fadeout then
				rc = rc - 1
				draw_cell(-1, b.y)
				draw_ball_alpha(b.cell - 1, -1, b.y, ALPHA_STEPS - b.step - 1);
				b.step = b.step + 1
				if b.step == ALPHA_STEPS then
					disable_effect(-1, x - 1)
					b.used = 0
					b.cell = 0
				end
			end
		end
	end
	return rc
end

function load_balls()
	local ball = sprite.load 'gfx/ball.png'
	local i, new, k

	for i=1, BALLS_NR + SPECIAL_BALLS do
		balls[i] = {}
		resized_balls[i] = {}
		jumping_balls[i] = {}
	end

	for i=1, BALLS_NR + SPECIAL_BALLS do
		if i == ball_joker then
			new = sprite.load 'gfx/joker.png'
			color = nil
		elseif i == ball_bomb then
			new = sprite.load 'gfx/atomic.png'
			color = nil
		elseif i == ball_brush then
			new = sprite.load 'gfx/paint.png'
			color = nil
		elseif i == ball_boom then
			new = sprite.load 'gfx/boom.png'
			color = nil
		else
			new = sprite.load ('gfx/color'..tostring(i)..'.png')
			sprite.draw(ball, new, 0, 0)
		end
		for k = 1, ALPHA_STEPS do
			local alph = sprite.alpha(new, (255 * 100) / (ALPHA_STEPS * 100 / k))
			balls[i][k] = alph
		end
		for k = 1, SIZE_STEPS do
			local cff = 1.0 / (SIZE_STEPS / k)
			local sized = sprite.scale(new, cff);
			resized_balls[i][k] = sized
		end 
		for k = 1, JUMP_STEPS do
			local cff = 1.0 - (((1.0 - JUMP_MAX)/JUMP_STEPS)*k)
			local jumped = sprite.scale(new, 1.0 + (1.0 - cff), cff);
			if not jumped then
				error "Fatal: jumping"
			end
			jumping_balls[i][k] = jumped
		end
		sprite.free(new)
	end
	sprite.free(ball)
end

function load_cell()
	cell = sprite.load 'gfx/cell.png'
end

function cell_to_screen(x, y)
	if x == -1 then
		x = BOARD_X - TILE_WIDTH - POOL_SPACE
		y = y * TILE_HEIGHT + TILE_HEIGHT * (BOARD_H - POOL_SIZE)/2 + BOARD_Y
		return x,y
	end
	x = x * TILE_WIDTH + BOARD_X
	y = y * TILE_HEIGHT + BOARD_Y
	return x, y
end

function draw_cell(x, y, tx, ty)
	local nx, ny, nx2, ny2
	nx, ny = cell_to_screen(x, y)
	if tx then
		nx2, ny2 = cell_to_screen(tx, ty)
	end
	if not tx then
		sprite.draw(bg, nx, ny, TILE_WIDTH, TILE_HEIGHT, sprite.screen(), nx, ny)
		sprite.draw(cell, sprite.screen(), nx, ny)
	else
		if nx2 < nx then nx, nx2 = nx2, nx; end
		if ny2 < ny then ny, ny2 = ny2, ny; end
		sprite.draw(bg, nx, ny, (nx2 - nx + TILE_WIDTH), (ny2 - ny + TILE_HEIGHT), sprite.screen(), nx, ny)
		sprite.draw(cell, sprite.screen(), nx, ny)
		sprite.draw(cell, sprite.screen(), nx2, ny2)
	end
end

function draw_ball_alpha_offset(n, alpha, x, y, dx, dy)
	local nx, ny = cell_to_screen(x, y)
	sprite.draw(balls[n + 1][alpha + 1], sprite.screen(), nx + 5 + dx, ny + 5 + dy);
end

function draw_ball_alpha(n, x, y, alpha)
--	print("alpha ball: n,x,y, alpha", n, x, y, alpha)
	draw_ball_alpha_offset(n, alpha, x, y, 0, 0);
end

function draw_ball_offset(n, x, y, dx, dy)
	draw_ball_alpha_offset(n, ALPHA_STEPS - 1, x, y, dx, dy);
end

function draw_ball(n, x, y)
	draw_ball_offset(n, x, y, 0, 0)
end

function draw_ball_size(n, x, y, size)
	local nx, ny = cell_to_screen(x, y)
	local img = resized_balls[n + 1][size + 1]
	local w,h = sprite.size(img)
	local diff = (TILE_WIDTH - w) / 2
	sprite.draw(img, sprite.screen(), nx + diff, ny + diff)
end

function draw_ball_jump(n, x, y, num)
	local nx, ny
	local img = jumping_balls[n + 1][num + 1]
	local w, h = sprite.size(img)
	local diff = (40 - h) + 5;
	local diffx = (TILE_WIDTH - w) /2
	nx, ny = cell_to_screen(x, y)
	sprite.draw(img, sprite.screen(), nx + diffx, ny + diff)
end

function fetch_game_board()
	local x,y
	for y = 1, BOARD_H do
		for x = 1, BOARD_W do
			game_board[x][y].cell = board_cell(x - 1, y - 1)
			if game_board[x][y].cell ~= 0 then
				game_board[x][y].x = x
				game_board[x][y].y = y
				game_board[x][y].used = 1
			end
		end
	end
end

function draw_board()
	local x,y
	sprite.draw(bg, BOARD_X, BOARD_Y, BOARD_WIDTH, BOARD_HEIGHT, sprite.screen(), BOARD_X, BOARD_Y)
	for y=1, BOARD_H do
		for x=1, BOARD_W do
			draw_cell(x - 1, y - 1)
			if game_board[x][y].cell ~= 0 and game_board[x][y].used ~= 0 then
				draw_ball(game_board[x][y].cell - 1, x - 1, y - 1);
			end
		end
	end
end

function draw_pool()
	local y
--	sprite.draw(bg, POOL_X, BOARD_Y, BOARD_WIDTH, BOARD_HEIGHT, sprite.screen(), BOARD_X, BOARD_Y)
	for y=1, POOL_SIZE do
		draw_cell(- 1, y - 1)
		if game_pool[y].cell ~= 0 and game_pool[y].used ~= 0 then
			draw_ball(game_pool[y].cell - 1, - 1, y - 1);
		end
	end
end

function load_bg()
	bg = sprite.load 'gfx/bg.png'
	bg2 = sprite.dup(bg)
end

function game_message(s)
	local t = sprite.text(font, s, 'white')
	local w,h = sprite.size(t)
	local x, y
	x = BOARD_X + (BOARD_WIDTH - w) / 2
	y = BOARD_Y + (BOARD_HEIGHT - h) / 2
	sprite.draw(t, sprite.screen(), x, y)
	sprite.free(t)
end

function load_font()
	font = sprite.font('gfx/circulat.ttf', 28);
end

score_timer = 0
score_x = SCORE_X + ((SCORE_W)/2);
score_w = 0
function min(a, b)
	if a < b then return a else return b end
end

function max(a, b)
	if a > b then return a else return b end
end

function show_score(force)
	if not info_mode then
		scr = sprite.screen()
	else
		scr = bg2
	end

	local new_score = board_score()
	local h
	if board_score_mul() < cur_mul then
		cur_mul = board_score_mul()
	end

	local w,h = sprite.text_size(font, "Bonus x"..tostring(board_score_mul()));

	if force or (new_score > cur_score or cur_score == -1) then
		if not force and board_score_mul() > cur_mul and board_score_mul() > 1
			and (score_timer % BONUS_BLINKS) then
			if score_timer == 0 then
				sound.play (bonus_snd)
			end
			local w,h = sprite.text_size(font, "Bonus x"..tostring(board_score_mul()));
			local x = SCORE_X + ((SCORE_W - w) / 2);
			sprite.draw(bg, min(x, score_x), SCORE_Y, max(w, score_w), h, scr, min(x, score_x), SCORE_Y);
			if (math.floor(score_timer / BONUS_BLINKS) % 2 ~= 0) then
				local t = sprite.text(font, "Bonus x"..tostring(board_score_mul()), 'white');
				sprite.draw(t, scr, x, SCORE_Y);
			end
			score_x = x
			score_w = w
			if score_timer == 0 then
				score_timer = BONUS_TIMER
			end
		elseif force or score_timer == 0 then
			if not force then
				cur_score = cur_score + 1
			else
				cur_score = new_score
			end
			local t = sprite.text(font, "SCORE "..tostring(cur_score), 'white');
			local w, h = sprite.size(t);
			local x = SCORE_X + ((SCORE_W - w) / 2)
			sprite.draw(bg, min(x, score_x), SCORE_Y, max(w, score_w), h, scr, min(x, score_x), SCORE_Y);
			sprite.draw(t, scr, x, SCORE_Y);
			score_x = x
			score_w = w
		end
	end
	if score_timer == 1 then
		cur_mul = board_score_mul()
	end
	if score_timer ~= 0 then
		score_timer = score_timer - 1
	end
end

function load_music(void)
	music_on = sprite.load "gfx/music_on.png";
	music_off = sprite.load "gfx/music_off.png";
	music_w,music_h = sprite.size(music_on)
	music_x = 0
	music_y = menu_y - music_h;
end

function load_info(void)
	info_on = sprite.load "gfx/info_on.png";
	info_off = sprite.load "gfx/info_off.png";
	info_w,info_h = sprite.size(info_on)
	info_x = 0
	info_y = music_y - info_h;
end

function load_menu(void)
	menu_on = sprite.load "gfx/menu.png";
	menu_w,menu_h = sprite.size(menu_on)
	menu_x = 4
	menu_y = 480 - menu_h;
end

function load_volume(void)
	vol_empty = sprite.load "gfx/vol_empty.png";
	vol_full = sprite.load "gfx/vol_full.png";
	vol_w,vol_h = sprite.size(vol_empty)
	vol_x = music_w + 4
	vol_y = 480 - vol_h;
end

function show_hiscores()
	local i
	local fh = sprite.font_height(font)
	local s 

	if not info_mode then
		sc = sprite.screen()
	else
		sc = bg2
	end

	sprite.draw(bg, SCORES_X, SCORES_Y, SCORES_W, fh * HISCORES_NR, sc, SCORES_X, SCORES_Y)
	for i=1, HISCORES_NR do
		local t = sprite.text(font, tostring(i)..'...', 'white')
		local s = sprite.text(font, tostring(prefs.hiscores[i]), 'white')
		local tw,th = sprite.size(t)
		local sw, sh = sprite.size(s)
		sprite.draw(t, sc, SCORES_X, SCORES_Y + i * fh);
		sprite.draw(s, sc, SCORES_X + SCORES_W - sw, SCORES_Y + i * fh);
	end
end
