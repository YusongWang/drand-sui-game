module drand_game::game_controller {
    use sui::bag::Bag;
    use sui::object::UID;
    use sui::object;
    use sui::tx_context::TxContext;
    use sui::bag;

    use sui::table_vec::TableVec;
    use sui::table_vec;
    use sui::clock;
    use sui::clock::Clock;
    use drand_game::drand;
    use sui::event;
    use drand_game::random;
    use sui::transfer::public_share_object;

    const GAME_COIN_FLIP: u64 = 1;

    const Opened:u64=0;
    const Completed:u64=1;

    const EGameAlreadyCompleted: u64=2;
    const ERoundNotFound:u64 =3;

    friend drand_game::coinFlip;

    //assert!(game.status != COMPLETED, EGameAlreadyCompleted);
    struct Game has key, store {
        id:UID,
        player: address,
        amount: u64,
        bet: u64,
        game: u64,
    }

    struct BetEvent has copy, drop {
        player: address,
        amount: u64,
        bet: u64,
        game: u64,
        round: u64,
    }

    struct GamePlay has copy, drop {
        game_id: u64,
        player: address,
        amount: u64,
        result: u64,
        random_number: u64,
        profit: u64,
        reward: u64,
    }

    struct Round has key, store {
        id: UID,
        games: TableVec<Game>,
        status:u64,
    }

    struct Controller has key, store {
        id: UID,
        rounds: Bag,
    }

    fun init(ctx:&mut TxContext) {
        let ctl = Controller{
            id:object::new(ctx),
            rounds:bag::new(ctx),
        };
        public_share_object(ctl);
    }

    public(friend) fun new_game(ctl:&mut Controller,clock:&Clock,player: address, amount: u64, bet: u64, game: u64,ctx:&mut TxContext) {
        let game_play = Game {
            id:object::new(ctx),
            player,
            amount,
            bet,
            game,
        };

        let timestamp = (clock::timestamp_ms(clock) / 1000);
        let currently_round = (timestamp - drand::get_genesis_time()) / 30;

        if (bag::contains(&ctl.rounds,currently_round)){
            let round = bag::borrow_mut<u64,Round>(&mut ctl.rounds,currently_round);
            table_vec::push_back(&mut round.games,game_play);
        } else {
            let games = table_vec::empty<Game>(ctx);
            table_vec::push_back(&mut games,game_play);

            let round = Round {
                id: object::new(ctx),
                games,
                status:Opened,
            };

            bag::add(&mut ctl.rounds,currently_round,round);
        };

        let event = BetEvent {
            player,
            amount,
            bet,
            game,
            round:currently_round,
        };

        event::emit(event);
    }

    public entry fun provide(ctl:&mut Controller,_clock:&Clock,drand_sig: vector<u8>, drand_prev_sig: vector<u8>,round:u64,_ctx:&mut TxContext) {
        drand::verify_drand_signature(drand_sig, drand_prev_sig, round);
        let digest = drand::derive_randomness(drand_sig);
        assert!(bag::contains(&ctl.rounds,round), ERoundNotFound);
        let round = bag::borrow_mut<u64,Round>(&mut ctl.rounds,round);
        assert!(round.status != Completed, EGameAlreadyCompleted);
        let len:u64 = table_vec::length(&round.games);
        let i:u64 = 0;
        while (i <len) {
            let game = table_vec::borrow(&round.games,i);
            if (game.game == GAME_COIN_FLIP) {
                coin_flip(game.player, game.amount, game.bet, digest);
            };

            i=i+1;
        }
    }

    fun coin_flip(player: address, amount: u64, number: u64, digest: vector<u8>) {
        let random_number = random::rand_u64_range_with_seed(digest, 0, 99);
        let result: u64 = 0;
        let profit: u64 = 0;
        if ((number == 0 && random_number < 49) || (number == 1 && random_number > 50)) {
            //win
            result = 1;
            // let win = vault::lose<T, LLP>(v, bet, ctx);
            // profit = coin::value(&win);
            // public_transfer(win, sender);
        } else {
            //lose
            //vault::win<T, LLP>(v, bet);
        };
        //let reward = get_reward(amount, r, ctx);

        event::emit(GamePlay {
            game_id: 1,
            player,
            amount,
            result,
            random_number,
            profit,
            reward: 0,
        })
    }
}
