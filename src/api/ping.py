import asyncio
import websockets

async def ping_pong_client(uri):
    """
    Connects to a WebSocket server, sends a "ping" message, and waits for a "pong" response.
    """
    try:
        async with websockets.connect(uri) as websocket:
            await websocket.send("ping")
            print("> ping")

            response = await websocket.recv()
            print(f"< {response}")

    except websockets.exceptions.ConnectionClosedError as e:
        print(f"WebSocket connection closed unexpectedly: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

async def main():
    uri = "ws://localhost/stream_messages/foo"  # Replace with your server's URI
    await ping_pong_client(uri)

if __name__ == "__main__":
    asyncio.run(main())