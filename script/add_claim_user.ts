import {
  JsonRpcProvider,
  Connection,
  Ed25519Keypair,
  RawSigner,
  TransactionBlock,
} from "@mysten/sui.js";

let main = async () => {
  const connection = new Connection({
    fullnode: "http://localhost:9000",
    faucet: "https://faucet.devnet.sui.io/gas",
  });

  const keypair = Ed25519Keypair.deriveKeypair(
    "champion husband stool water list poet problem trick hood daring symptom resemble"
  );

  const pkg =
    "0x46949b1f790d60514606dc27b905c7707802c4a16be60d60bcc464129b65a87c";

  const provider = new JsonRpcProvider(connection);

  /*   let events = provider.queryEvents({ query: { Package: pkg } });
  console.log(events); */

  let blk = await provider.getTransactionBlock({
    digest: "LNLtDEydHSfagqHdzQBRbF9ZiebTGRC4cAc4CZiRrpe",
    options: {
      showEvents: true,
    },
  });
  blk.events?.forEach((e) => {
    console.log(e);
  });

  return;

  const signer = new RawSigner(keypair, provider);

  const txBlock = new TransactionBlock();
  txBlock.setGasBudget(1000000000);
  let root =
    "94570875849a2f8b20ccc64676fe693ab0e1cab5558760b88054d341dcfa25d30dd77210c1bcc708c72f27f02d32e9d419fe99561e6215b23256a4da9e9db2595f2d7d9035cadc0a6383f82812fa91fc45483c1a71b3e2041ab61f3d316dfcbf";

  let root1 = Buffer.from(root, "hex");
  console.log(root);
  let root2 = [].slice.call(root1);

  let prev =
    "b64c0d58a10d9b553b8deee5bedbbb04efa4eab996e74adbe0f5c13d35d0e49c6344b2c14349c09de2b2f62da7c68bf300ecbdc2a67921425b9001b0a1bec171986a69bd8d2abff33b8bd7603616b6e944e5d9efcb2320e7f9dce83ad7dde61f";

  let prev1 = Buffer.from(prev, "hex");
  console.log(root);
  let prev2 = [].slice.call(prev1);

  txBlock.moveCall({
    target: `${pkg}::game_controller::provide`,
    arguments: [
      txBlock.object(
        "0x0f9b311724a1e042ba8965de92f9b99de2200a4dae43c3061e3bde90f48c170c"
      ),
      txBlock.object("0x6"),
      txBlock.pure(root2),
      txBlock.pure(prev2),
      txBlock.pure("2942312"),
    ],
  });

  const result = await signer.signAndExecuteTransactionBlock({
    transactionBlock: txBlock,
    options: {
      showEffects: true,
      showObjectChanges: true,
    },
  });

  console.log({ result });
};

main();
