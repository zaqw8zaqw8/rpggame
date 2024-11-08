import 'dart:io';
import 'dart:math';

void loadCharacterStats(String name) {
  try {
    final file = File('characters.txt');
    final contents = file.readAsStringSync();
    final stats = contents.split(',');
    if (stats.length != 3) throw FormatException('Invalid character data');
      
    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);
      
    character = Character(name, health, attack, defense);
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

void loadMonsterStats() {
  try {
    final file = File('monsters.txt');
    final lines = file.readAsLinesSync();
    monsters = [];

    for (var line in lines) {
      final stats = line.split(',');
      if (stats.length != 3) throw FormatException('Invalid monster data');

      String name = stats[0];
      int health = int.parse(stats[1]);
      int maxAttackPower = int.parse(stats[2]);
      int attackPower = max(1, Random().nextInt(maxAttackPower) + 1);  // 공격력은 최소 1 이상으로 설정
      monsters.add(Monster(name, health, attackPower));
    }
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

String getCharacterName() {
  while (true) {
    stdout.write('캐릭터 이름을 입력하세요: ');
    String? name = stdin.readLineSync();
    RegExp validNamePattern = RegExp(r'^[a-zA-Z가-힣]+\$');
    if (name == null || name.isEmpty || !validNamePattern.hasMatch(name)) {
      print('올바른 이름을 입력해주세요. (영문 또는 한글만 허용)');
    } else {
      return name;
    }
  }
}

class Character {
  String name;
  int health;
  int attackPower;
  int defense;

  Character(this.name, this.health, this.attackPower, this.defense);

  void attackMonster(Monster monster) {
    int damage = max(0, attackPower - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 피해를 입혔습니다!');
  }

  void defend(int monsterDamage) {
    health += monsterDamage;
    print('\$name이(가) 방어하여 체력이 \$monsterDamage 만큼 회복되었습니다! 현재 체력: \$health'); {
    health += damage;
    print('$name이(가) 방어하여 체력이 $damage 만큼 회복되었습니다! 현재 체력: $health');
  }

  void showStatus() {
    print('캐릭터 상태 - 이름: \$name, 체력: \$health, 공격력: \$attackPower, 방어력: \$defense');
  }

  void showMonsterStatus(Monster monster) {
    print('몬스터 상태 - 이름: \${monster.name}, 체력: \${monster.health}, 공격력: \${monster.attackPower}');
  }
}

class Monster {
  String name;
  int health;
  int attackPower;
  int defense = 0;
  String name;
  int health;
  int attackPower;
  int defense = 0;

  Monster(this.name, this.health, this.attackPower);

  void attackCharacter(Character character) {
    int damage = max(0, attackPower - character.defense);
    character.health -= damage;
    print('$name이(가) ${character.name}에게 $damage의 피해를 입혔습니다!');
    // 캐릭터가 방어할 경우 피해만큼 체력을 회복
    character.defend(damage);
  }
}

List<Monster> monsters = [];
Character? character;

class Game {
  bool gameRunning = true;
  int defeatedMonsterCount = 0;
  bool gameRunning = true;

  void startGame() {
    String name = getCharacterName();
    loadCharacterStats(name);
    bool gameSaved = false;
    loadCharacterStats();
    loadMonsterStats();

    print('게임이 시작되었습니다!');
    print('캐릭터: ${character?.name}, 체력: ${character?.health}, 공격력: ${character?.attackPower}, 방어력: ${character?.defense}');

    while (gameRunning) {
      print('\n[1] 몬스터와 전투하기');
      print('[2] 캐릭터 상태 보기');
      print('[3] 게임 종료하기');
      stdout.write('선택지를 입력하세요: ');
      String? input = stdin.readLineSync();

      switch (input) {
        case '1':
          if (monsters.isEmpty) {
            print('모든 몬스터를 물리쳤습니다! 축하합니다!');
            gameRunning = false;
          } else {
            Monster monster = getRandomMonster();
            battleMenu(character!, monster);
          }
          break;
        case '2':
          character?.showStatus();
          break;
        case '3':
          print('게임을 종료합니다. 수고하셨습니다!');
          saveGameResult();
          saveGameResult();
          gameRunning = false;
          break;
        default:
          print('올바른 번호를 입력해주세요.');
      }
    }
  }

  void battle(Character character, Monster monster) {
    print('\n${monster.name}이(가) 나타났습니다!');

    while (character.health > 0 && monster.health > 0) {
      print('\n[1] 공격하기');
      print('[2] 방어하기');
      stdout.write('선택지를 입력하세요: ');
      String? input = stdin.readLineSync();

      switch (input) {
        case '1':
          character.attack(monster);
          if (monster.health <= 0) {
            print('${monster.name}을(를) 물리쳤습니다!');
            break;
          }
          monster.attackCharacter(character);
          character.showMonsterStatus(monster);
          break;
        case '2':
          int damageRecovered = max(0, monster.attackPower - character.defense);
          character.defend(damageRecovered);
          monster.attackCharacter(character);
          character.showMonsterStatus(monster);
          break;
        default:
          print('올바른 번호를 입력해주세요.');
      }

      if (character.health <= 0) {
        print('${character.name}이(가) 패배했습니다... 게임이 종료됩니다.');
        gameRunning = false;
      }
    }
  }
}

void saveGameResult() {
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? input = stdin.readLineSync();
    if (input != null && input.toLowerCase() == 'y') {
      try {
        final file = File('result.txt');
        String result = '''
캐릭터 이름: \${character?.name}
남은 체력: \${character?.health}
게임 결과: \${(character != null && character!.health > 0) ? '승리' : '패배'}
''';
        result += (character != null && character!.health > 0) ? '승리' : '패배';
        file.writeAsStringSync(result);
        print('결과가 result.txt 파일에 저장되었습니다.');
      } catch (e) {
        print('결과를 저장하는 데 실패했습니다: $e');
      }
    }
  }

void main() {
  Game game = Game();
  game.start();
  saveGameResult();
}

void saveGameResult() {
  stdout.write('결과를 저장하시겠습니까? (y/n): ');
  String? input = stdin.readLineSync();
  if (input != null && input.toLowerCase() == 'y') {
    try {
      final file = File('result.txt');
      String result = '캐릭터 이름: ${character?.name}
남은 체력: ${character?.health}
게임 결과: ';
      result += (character != null && character!.health > 0) ? '승리' : '패배';
      file.writeAsStringSync(result);
      print('결과가 result.txt 파일에 저장되었습니다.');
    } catch (e) {
      print('결과를 저장하는 데 실패했습니다: $e');
    }
  } else {
    print('결과 저장이 취소되었습니다.');
  }
}
