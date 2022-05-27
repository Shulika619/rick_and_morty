import 'package:flutter/material.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rick_and_morty/ui/widgets/character_status.dart';

class CustomListTile extends StatelessWidget {
  final Results result;
  const CustomListTile({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: MediaQuery.of(context).size.height / 7,
        color: const Color.fromRGBO(86, 86, 86, 0.8),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: result.image,
              placeholder: (context, url) => const CircularProgressIndicator(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.9,
                    child: Text(result.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CharacterStatus(
                      liveState: result.status == 'Alive'
                          ? LiveState.alive
                          : result.status == 'Dead'
                              ? LiveState.dead
                              : LiveState.unknown),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Species',
                                style: Theme.of(context).textTheme.caption),
                            const SizedBox(height: 2),
                            Text(result.species,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyText1)
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gender',
                                style: Theme.of(context).textTheme.caption),
                            const SizedBox(height: 2),
                            Text(result.gender,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyText1)
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ListTile(
//       title: Text(
//         result.name,
//         style: const TextStyle(color: Colors.white),
//       ),
//     )