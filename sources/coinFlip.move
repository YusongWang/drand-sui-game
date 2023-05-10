module drand_game::coinFlip {

    use sui::coin::Coin;
    use sui::tx_context::TxContext;
    use drand_game::game_controller;
    use drand_game::game_controller::Controller;

    use sui::clock::Clock;
    use sui::coin;
    use sui::transfer::public_transfer;
    use sui::tx_context;


    public entry fun play<T>(
        ctl:&mut Controller,
        clock:&Clock,
        paid: Coin<T>,
        number: u64,
        ctx: &mut TxContext
    ) {
        assert!(number == 0 || number == 1, 1);
        let amount = coin::value(&paid);
        public_transfer(paid, tx_context::sender(ctx));
        game_controller::new_game(ctl,clock,tx_context::sender(ctx),amount,number,1,ctx);
    }
}
