#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    lua_State *L = luaL_newstate();  // Create a new Lua state
    luaL_openlibs(L);  // Load Lua standard libraries

    // Load and run the Lua testbench file
    if (luaL_dofile(L, "testbench.lua")) {
        fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Disable garbage collection
    lua_gc(L, LUA_GCSTOP, 0);

    // Run the test function
    lua_getglobal(L, "test");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
        fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Re-enable garbage collection before closing (optional, for cleanup purposes)
    lua_gc(L, LUA_GCRESTART, 0);

    lua_close(L);
    return 0;
}
