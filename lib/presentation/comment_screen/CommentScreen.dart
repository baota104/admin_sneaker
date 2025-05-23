import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../datasource/model/CommentModel.dart';
import 'Comment_provider.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CommentModel> _filteredComments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false).fetchComments();
    });
    _searchController.addListener(_filterComments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterComments() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<CommentProvider>(context, listen: false);

    setState(() {
      _filteredComments = provider.comments.where((comment) {
        return comment.content.toLowerCase().contains(query) ||
            comment.username.toLowerCase().contains(query) ||
            comment.rating.toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Comment Management"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search comments...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CommentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.comments.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          final commentsToDisplay =
          _searchController.text.isEmpty ? provider.comments : _filteredComments;

          if (commentsToDisplay.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.comment_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    _searchController.text.isEmpty
                        ? "No comments found!"
                        : "No matching comments found",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: commentsToDisplay.length,
            itemBuilder: (context, index) {
              final comment = commentsToDisplay[index];
              return _buildCommentItem(comment, screenWidth, screenHeight, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, double screenWidth, double screenHeight, BuildContext context) {
    return Slidable(
      key: ValueKey(comment.userId),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            width: screenWidth * 0.2,
            height: screenHeight * 0.12,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => _confirmDeleteComment(context, comment.cmtId),
            ),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(comment.avatarUrl),
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < comment.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  Spacer(),
                  Switch(
                    value: comment.isVisible,
                    onChanged: (value) async {
                      try {
                        await Provider.of<CommentProvider>(context, listen: false)
                            .toggleCommentVisibility(comment.cmtId, value);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error updating status: ${e.toString()}")),
                        );
                      }
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                comment.content,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(comment.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteComment(BuildContext context, String commentId) async {
    final TextEditingController _reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Comment Deletion Reason"),
        content: TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            hintText: "Enter deletion reason (e.g., inappropriate language)...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _reasonController.text.isNotEmpty
                  ? _reasonController.text
                  : "Violation of community standards");
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );

    if (reason != null) {
      try {
        await Provider.of<CommentProvider>(context, listen: false)
            .deleteComment(commentId, reason);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Comment deleted and user notified")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting comment: ${e.toString()}")),
        );
      }
    }
  }
}