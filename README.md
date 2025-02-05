# example-godot-threaded-load-autoload-bug

A repository demonstrating an issue trying to background load a script which references an autoloaded scene.

## Issue description

Given an autoloaded scene, `AutoLoad`, and a script which references `Autoload`, `caller.gd`, attempting to background load a node which attaches `caller.gd` as a script _with `use_sub_threads` enabled_ will produce an engine error:

```
E 0:00:08:0459   get_script: Caller thread can't call this function in this node (/root/Autoload). Use call_deferred() or call_thread_group() instead.
  <C++ Error>    Condition "!is_accessible_from_caller_thread()" is true. Returning: (Variant())
  <C++ Source>   scene/main/node.cpp:3864 @ get_script()
```

Note that this error does not seem to prevent the loaded scene from running correctly.

## Reproduction steps

1. Clone this repository:

    ```sh
    git clone https://github.com/coffeebeats/example-godot-threaded-load-autoload-bug.git
    ```

2. Run the `main.tscn` scene via the editor (it's set as the project's default scene).

3. Adjust the `Main` scene's options:

- `load_on_ready`: load_on_ready controls whether this node will attempt a load within its `_ready` callback. Anecdotally, the bug is almost always observed when this is `true`, but rarely observed when `false` (and loads are instead triggered via button press).
- `use_sub_threads`: Toggles the `use_sub_threads` passed to `ResourceLoader`; this property is the primary trigger of this bug; when it's `false`, the bug is not observed.
