import React, { useState, useEffect, useRef } from "react";
import * as Realm from "realm-web";
import { useTransition, animated } from "react-spring";
import { timeSince } from "./utils";
import { tokenImages, tokenTicker } from "./tokenImages";
import { OpenNewWindow, User } from "iconoir-react";
import { Reorder } from "framer-motion";
const app = new Realm.App({ id: "application-0-oolcn" });

type Swap = {
  _id: string;
  exchange: string;
  sell_token: string;
  buy_token: string;
  pair: string;
  block_number: number;
  block_time: number;
  transaction_hash: string;
  taker_address: string;
  sell_amount: number;
  buy_amount: number;
  beneficiary_address: string;
  timestamp: string;
};

const App = () => {
  const [user, setUser] = useState<Realm.User | null>(null);
  const [displayEvents, setDisplayEvents] = useState<Swap[]>([]);
  const prevDisplayEventsRef = useRef<string[]>([]);

  useEffect(() => {
    const login = async () => {
      const user = await app.logIn(Realm.Credentials.anonymous());
      setUser(user);

      if (app.currentUser === null) {
        console.log("No user logged in");
        return;
      }

      const mongodb = app.currentUser.mongoClient("mongodb-atlas");
      const collection = mongodb
        .db(process.env.MONGO_DATABASE_NAME)
        .collection("swaps");

      const initialData = await collection.find(
        {},
        { sort: { block_time: -1 } },
      );
      setDisplayEvents(initialData);
      console.log("initialData", initialData);

      for await (const change of collection.watch()) {
        if (change.operationType === "insert") {
          setDisplayEvents((prevDisplayEvents) => {
            // Use the most recent state to check if the event already exists
            const newSwap = change.fullDocument as Swap;
            const exists = prevDisplayEvents.some(
              (swap) => swap._id.toString() === newSwap._id.toString(),
            );
            console.log("events", prevDisplayEvents);
            console.log("change", change);
            console.log("exists", exists);
            if (!exists) {
              // If it doesn't exist, prepend the new event
              return [newSwap, ...prevDisplayEvents];
            } else {
              // If it does exist, just return the previous state
              return prevDisplayEvents;
            }
          });
        } else if (change.operationType === "delete") {
          setDisplayEvents((prevDisplayEvents) => {
            // Use the most recent state to remove the event
            const idToDelete = change.documentKey._id.toString();
            console.log("idToDelete", idToDelete);
            return prevDisplayEvents.filter(
              (swap) => swap._id.toString() !== idToDelete,
            );
          });
        }
      }
    };
    login();
  }, []);

  useEffect(() => {
    // Update the ref to hold the current IDs of displayEvents
    prevDisplayEventsRef.current = displayEvents.map((item) => item._id);
  }, [displayEvents]); // This effect runs whenever displayEvents changes

  const isItemNew = (id: string) => {
    return !prevDisplayEventsRef.current.includes(id);
  };

  function addItem(): void {
    setDisplayEvents((prevDisplayEvents) => {
      if (prevDisplayEvents.length > 0) {
        const firstElement = { ...prevDisplayEvents[0] };
        return [firstElement, ...prevDisplayEvents];
      }
      return prevDisplayEvents;
    });
  }

  return (
    <div className="App">
      <div className="text-3xl font-bold text-center mt-10">MiniSwapScan</div>
      {/*  
      <button onClick={() => addItem()}>Add Item(For testing animation purposes)</button>
      */}
      {!!user && (
        <div className="App-header">
          {/* Block Quote */}
          <div className="text-center bg-gray-100 p-4 rounded-lg shadow-md">
            <blockquote className="italic">
              <p className="mb-4">
                Welcome to a demonstration app utilizing Apibara to create a
                real-time swap scanner.
                <a
                  href="https://github.com/machuwey/apibara-example-server"
                  target="_blank"
                  rel="noreferrer"
                  className="text-blue-500 hover:text-blue-700"
                >
                  View the server code
                </a>
                . This application operates by indexing and streaming AVNU
                contract swap events into a MongoDB database, allowing the
                frontend to listen for new swap events and display them in
                real-time.
              </p>
              <p>
                Leverage this technology to build any real-time application
                imaginable, from dynamic dashboards to instant notifications, or
                even to index an NFT collection.
              </p>
            </blockquote>
          </div>
          <div>
            <Reorder.Group
              axis="y"
              values={displayEvents}
              onReorder={setDisplayEvents}
            >
              <table className="table-auto w-full">
                <thead>
                  <tr>
                    <td>Index</td>
                    <td>Operation</td>
                    <td>Taker Address</td>
                    <td>Transaction Hash</td>
                    <td>Block Time</td>
                  </tr>
                </thead>

                <Reorder.Group
                  as="tbody"
                  axis="y"
                  values={displayEvents}
                  onReorder={setDisplayEvents}
                >
                  {displayEvents.map((item, index) => (
                    <Reorder.Item
                      key={item._id}
                      value={item}
                      as="tr"
                      initial={{ y: isItemNew(item._id) ? -50 : 0, opacity: 0 }}
                      animate={{ y: 0, opacity: 1 }}
                      exit={{ opacity: 0 }}
                      transition={{
                        type: "spring",
                        stiffness: 300,
                        damping: 30,
                      }}
                    >
                      <td>{index}</td>

                      {/*
                    <td>{item.documentKey._id.toString()}</td>
                    */}

                      {/* From x to y  section */}
                      <td>
                        <div className="flex flex-row items-center">
                          <div className="flex flex-row items-center">
                            <img
                              src={
                                tokenImages[item.sell_token] ||
                                "default_image_path"
                              }
                              alt="Sell Token"
                              className="h-6 w-6"
                            />
                            <div>{Number(item.sell_amount).toFixed(5)}</div>
                            <div>{tokenTicker[item.sell_token]}</div>
                          </div>
                          <div className="flex flex-row items-center">
                            {"->"}
                          </div>
                          <div className="flex flex-row items-center">
                            <img
                              src={
                                tokenImages[item.buy_token] ||
                                "default_image_path"
                              }
                              alt="Buy Token"
                              className="h-6 w-6"
                            />
                            <div>{Number(item.buy_amount).toFixed(5)}</div>
                            <div>{tokenTicker[item.buy_token]}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        <div className="flex flex-row items-center">
                          <a
                            href={`https://voyager.online/contract/${item.taker_address}`}
                            target="_blank"
                            rel="noreferrer"
                            className="flex flex-row items-center"
                          >
                            <User className="h-6 w-6" />
                            <div>
                              {`${item.taker_address.substring(0, 12)}...`}
                            </div>
                            <OpenNewWindow className="h-6 w-6" />
                          </a>
                        </div>
                      </td>
                      <td>
                        <div className="flex flex-row items-center">
                          <div>Tx</div>
                          <a
                            href={`https://voyager.online/tx/${item.transaction_hash}`}
                            target="_blank"
                            rel="noreferrer"
                            className="flex flex-row items-center"
                          >
                            <div>
                              {`${item.transaction_hash.substring(0, 12)}...`}
                            </div>
                            <OpenNewWindow className="h-6 w-6" />
                          </a>
                        </div>
                      </td>

                      <td>{timeSince(new Date(item.block_time * 1000))}</td>
                    </Reorder.Item>
                  ))}
                </Reorder.Group>
              </table>
            </Reorder.Group>
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
