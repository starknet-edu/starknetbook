import { MongoClient } from "mongodb";
import * as dotenv from "dotenv";
dotenv.config();

export class MongoDBService {
  private static uri = process.env.MONGO_DB_URI;
  private static dbName = "apibara-example";
  private static client: MongoClient;

  static async getClient() {
    if (!this.client) {
      if (!this.uri) {
        throw new Error(
          "DB_CONNECTION is not defined in the environment variables.",
        );
      }
      this.client = new MongoClient(this.uri);
      await this.client.connect();
      console.log("Connected to MongoDB");
    }
    return this.client;
  }

  static async getDb() {
    const client = await this.getClient();
    return client.db(this.dbName);
  }

  static async clearCollection(collectionName: string) {
    const db = await this.getDb();
    const collection = db.collection(collectionName);
    await collection.deleteMany({});
    console.log("Collection cleared");
  }

  static async insertSwapData(collectionName: string, swapData: any) {
    const db = await this.getDb();
    const collection = db.collection(collectionName);

    // Insert the new document first
    await collection.insertOne(swapData);
    console.log("Swap data saved to MongoDB");

    // Ensure there are only 20 documents in the collection
    const count = await collection.countDocuments();
    if (count > 20) {
      const excess = count - 20;
      // Find and delete the oldest documents based on the excess count
      const oldestDocuments = await collection
        .find()
        .sort({ block_time: 1 })
        .limit(excess)
        .toArray();
      for (const doc of oldestDocuments) {
        await collection.deleteOne({ _id: doc._id });
        console.log("Deleted oldest document from MongoDB");
      }
    }
  }
}
