import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:show_app_frontend/config/api_config.dart';
import 'package:show_app_frontend/screens/add_show_page.dart';
import 'package:show_app_frontend/screens/update_show_page.dart';
import 'package:show_app_frontend/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/shows'));

      if (response.statusCode == 200) {
        List<dynamic> allShows = jsonDecode(response.body);

        setState(() {
          movies = allShows.where((show) => show['category'] == 'movie').toList();
          anime = allShows.where((show) => show['category'] == 'anime').toList();
          series = allShows.where((show) => show['category'] == 'serie').toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load shows: ${e.toString()}")),
      );
    }
  }

  Future<void> deleteShow(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/shows/$id'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Show deleted successfully")),
        );
        fetchShows(); // Refresh list after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete show")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteShow(id);
            },
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  void navigateToAddShow() async {
    // Attend le résultat de la navigation
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (builder) => const AddShowPage())
    );
    
    // Si le résultat est true, rafraîchir la liste
    if (result == true) {
      fetchShows();
    }
  }

  void navigateToUpdateShow(Map<String, dynamic> show) async {
    // Attend le résultat de la navigation
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (builder) => UpdateShowPage(show: show))
    );
    
    // Si le résultat est true, rafraîchir la liste
    if (result == true) {
      fetchShows();
    }
  }

  Widget _getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return ShowList(
          shows: movies, 
          onDelete: confirmDelete,
          onEdit: navigateToUpdateShow,
        );
      case 1:
        return ShowList(
          shows: anime, 
          onDelete: confirmDelete,
          onEdit: navigateToUpdateShow,
        );
      case 2:
        return ShowList(
          shows: series, 
          onDelete: confirmDelete,
          onEdit: navigateToUpdateShow,
        );
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleRefresh() async {
    await fetchShows();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App"), 
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchShows,
            tooltip: "Refresh Shows",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (builder) => const ProfilePage())
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                navigateToAddShow(); // Navigue vers AddShowPage et récupère le résultat
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _getBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddShow,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  final List<dynamic> shows;
  final Function(int) onDelete;
  final Function(Map<String, dynamic>) onEdit;

  const ShowList({
    super.key, 
    required this.shows, 
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) {
      return const Center(child: Text("No Shows Available"));
    }

    return ListView.builder(
      itemCount: shows.length,
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(show['id']),
          confirmDismiss: (direction) async {
            bool? result = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete Show"),
                content: const Text("Are you sure you want to delete this show?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes, Delete"),
                  ),
                ],
              ),
            );
            return result ?? false;
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.network(
                ApiConfig.baseUrl + show['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
              title: Text(show['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(show['description']),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit(show);
                  } else if (value == 'delete') {
                    onDelete(show['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => onEdit(show), // Permet d'éditer en cliquant sur l'élément
            ),
          ),
        );
      },
    );
  }
}