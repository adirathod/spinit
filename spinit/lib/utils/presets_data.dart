import '../models/wheel_segment.dart';
import 'colors.dart';
import '../models/preset_pack.dart';

List<WheelSegment> _buildSegments(List<String> labels) {
  return List.generate(
    labels.length,
    (index) => WheelSegment(
      label: labels[index],
      color: paletteColor(index),
    ),
  );
}

final List<PresetPack> presetPacks = [
  PresetPack(
    id: 'food_1',
    name: 'What to Eat?',
    icon: '🍕',
    segments: _buildSegments([
      'Pizza', 'Burger', 'Sushi', 'Tacos',
      'Pasta', 'Salad', 'Ramen', 'Sandwich'
    ]),
  ),
  PresetPack(
    id: 'game_1',
    name: 'Who Goes First?',
    icon: '🎮',
    segments: _buildSegments([
      'Player 1', 'Player 2', 'Player 3', 'Player 4'
    ]),
  ),
  PresetPack(
    id: 'party_1',
    name: 'Truth or Dare',
    icon: '🔥',
    segments: _buildSegments([
      'Truth', 'Dare', 'Truth', 'Dare', 'Skip', 'Double Dare'
    ]),
  ),
  PresetPack(
    id: 'watch_1',
    name: 'What to Watch?',
    icon: '🎬',
    segments: _buildSegments([
      'Action Movie', 'Rom-Com', 'Documentary',
      'Horror', 'Anime', 'Comedy Series', 'Thriller', 'Cartoon'
    ]),
  ),
  PresetPack(
    id: 'leisure_1',
    name: 'Weekend Activity',
    icon: '😴',
    segments: _buildSegments([
      'Go for a Walk', 'Read a Book', 'Call a Friend',
      'Cook Something New', 'Watch a Movie', 
      'Play a Game', 'Nap Time 😴', 'Workout'
    ]),
  ),
  PresetPack(
    id: 'dice_1',
    name: 'Random Number',
    icon: '🎲',
    segments: _buildSegments([
      '1', '2', '3', '4', '5', '6', '7', '8'
    ]),
  ),
];
