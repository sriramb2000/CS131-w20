PORT_NUMBERS = {
    "Hill": 11860,
    "Jaquez": 11861,
    "Smith": 11862,
    "Campbell": 11863,
    "Singleton": 11864,
}

TEST_PORT_NUMBERS = {
    "Hill": 8001,
    "Jaquez": 8002,
    "Smith": 8003,
    "Campbell": 8004,
    "Singleton": 8005,
    "hello": 8888,
}

LINKS = {
    "Hill": ["Jaquez", "Smith"],
    "Jaquez": ["Hill", "Singleton"],
    "Smith": ["Hill", "Singleton", "Campbell"],
    "Campbell": ["Singleton", "Smith"],
    "Singleton": ["Jaquez", "Smith", "Campbell"],
}
