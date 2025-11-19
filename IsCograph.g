# SPLIT THIS CODE INTO MULTIPLE FUNCTIONS - IT'S A MESS 

IsCograph := function(D)
  local x, neighbors, origin, adj, verts, P, part, pivot, 
        neighbours, refine, unused_parts, current_part, y, 
        N_y, refined_parts, zl, zr, adj_zl, adj_zr, found, v;
  # check if D is a digraph
  if not IsSymmetricDigraph(D) then;
    Error("IsCograph: argument must be a symmetric digraph");
  fi;

  verts := DigraphVertices(D);
  P := [verts];

# pick a vertex of G as the origin (choose first one)
  origin := verts[1];
# if a universal or isolated vertex, recurse on all other vertices without it (i.e. remove it)
  adj := OutNeighboursOfVertex(D, origin);
  if Length(adj) = 0 or Length(adj) = Length(verts) - 1 then
    return IsCograph(InducedSubdigraph(D, Filtered(verts, v -> v <> origin)));
  fi;

# while there are non-singletons

#ISSUES - CHECK THE MATHS IS CORRECT ON THIS
  while not ForAll(P, part -> Length(part) = 1) do

# if a part of the partition is not a singleton part, then:
# find a non-singleton part
# MAKE A PARTITION P

    part := P[]
      if Length(part) > 1 then
        # pick an arbitrary vertex from the part as pivot
          pivot := part[1];
          neighbors := OutNeighboursOfVertex(D, pivot);
          # split the part into N'\int part, origin, N\int part - set as unused parts
          refine := [[Intersection(neighbours, part)], [pivot], [Intersection(part, not neighbors)]];
          unused_parts := [[Intersection(neighbors, part)], [Intersection(part, not neighbors)]];
    
# while there exist unused parts
# pick an arbitrary unused part and a vertex of the part
# set y as the pivot
# refine the parts of P using the pivot set N(y)

        while Length(unused_parts) > 0 do
          current_part := unused_parts[1];
          y := current_part[1];
          N_y := OutNeighbours(D, y);
          refined_parts := [[Intersection(N_y, current_part)], [y], [Difference(current_part, N_y)]];
          Remove(unused_parts, 1);
          Add(unused_parts, refined_parts);
        od;
      fi;
  od;
  #let zl and zr be the pivots of the nearest non-singleton parts to Origin respectievly on the left and right
  for part in P do
    if Length(part) > 1 then
      if Position(verts, part[1]) < Position(verts, origin) then
        zl := part[1];
      else
        zr := part[1];
        break;
      fi;
    fi;
  od;

  if zl = fail or zr = fail then
    break;
  fi;

  adj_zl := OutNeighborsOfVertex(D, zl);
  adj_zr := OutNeighborsOfVertex(D, zr);

  found := false;
  for v in verts do
    if v <> zl and v <> zr then
      if (v in adj_zl) <> (v in adj_zr) then
        found := true;
        break;
      fi;
    fi;
  od;
    
  if found then
    return false;
  fi;

  if origin = zl then
    origin := zr;
  else
    origin := zl;
  fi;
od;
return true;

end;