# Hearts For Tainted Lost!!!!

## Introduction

Ever felt punished just for picking **Tainted Lost**? Yeah… me too. The idea for this mod came from my endless frustration playing this character. The game punishes you relentlessly, and holy cards are supposed to give you a chance to survive a single hit—but in my experience, after the first holy card, it felt like there were never any more.

So I thought: “What if we finally make those useless hearts actually useful for the Lost characters?” Normally, Lost characters can’t interact with hearts at all—they just stare at them sadly. This mod changes that. Now, **every heart type benefits the player in some way**. On top of that, while playing Lost, hearts will no longer appear for sale in shops—they’re replaced with other items. Finally, your poor Lost character can feel like picking up a heart actually matters.



## How the Mod Works

This mod dynamically converts heart pickups into other items using **handlers** and a **queue system**. Each heart type has a **handler** that defines what happens when it morphs or interacts with the player.

### Key Concepts

- **Handler Table**: Defines the behavior of a heart type.
  - `onMorph(pickup, meta)`: Returns a **plan table** describing how the heart should transform (e.g., into coins, keys, bombs, tarot cards, or custom effects).
  - `onCollision(pickup, player)`: Optional; defines immediate effects when the heart is touched (used for black hearts, for example).

- **Plan Table Actions**:
  - `"morph"`: Changes the heart into another pickup (coins, keys, bombs, tarot cards, etc.).
  - `"custom"`: Executes a function, giving full control over the behavior (spawn allies, trigger effects, etc.).
  - `"spawn_chest"`: Spawns and opens a chest at the heart’s position.

- **Queue System**: Instead of converting hearts immediately, the mod **queues morphs** to happen a few frames later. This ensures that effects like the angelic lightning strike play smoothly before the pickup is converted.



## Creating a Custom Heart Conversion

You can add your own heart conversion by registering a new handler. Here's the basic structure:

```lua
TL.RegisterHeartHandler(HeartSubType.YOUR_CUSTOM_HEART, {
    onMorph = function(pickup, meta)
        local rng = pickup:GetDropRNG()

        -- Example: convert your custom heart into coins or keys
        local roll = rng:RandomFloat()
        if roll < 0.5 then
            return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_PENNY }
        else
            return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_KEY, subtype = 0 }
        end
    end,
    onCollision = function(pickup, player)
        -- Optional: define immediate effect when the heart is touched
    end
})
```

### Notes:

- **`meta` parameter**: Contains contextual info. Not being used at the moment.
- **Morph vs Custom**:
  - **Morph**: Converts the heart into another pickup automatically.
  - **Custom**: Lets you run Lua code, spawn entities, or apply effects. For example, spawning a blue fly or spider for rotten hearts.
- **Queue System**: Use `TL.QueueMorph(pickup, delayFrames, handler, meta)` if you want to trigger additional morphs or effects manually.


## Example: Creating a Custom Conversion

Suppose we want a new heart type, **Golden Heart**, that turns into a random reward: either a golden key or a random coin. Here's how it looks:

```lua
TL.RegisterHeartHandler(HeartSubType.HEART_GOLDEN, {
    onMorph = function(pickup, meta)
        local rng = pickup:GetDropRNG()
        if rng:RandomInt(2) == 0 then
            return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_KEY, subtype = KeySubType.KEY_GOLDEN }
        else
            return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_PENNY }
        end
    end
})
```

Now every Golden Heart will morph to either a golden key or a penny, with a 50/50 chance.

This approach can be used for **any heart type**.

