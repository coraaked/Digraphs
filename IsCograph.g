<<<<<<< HEAD

IsCograph := function(D)
  local x, neighbours, origin, adj, verts, P, part, pivot, 
        refine, unused_parts, current_part, y, 
        N_y, refined_parts, zl, zr, adj_zl, adj_zr, found,
        p,u,v;
=======
IsCograph := function(D)
  local x, neighbours, origin, adj, verts, P, part, pivot, 
        refine, unused_parts, current_part, y, 
        N_y, refined_parts, used_parts, unused_parts_refined, zl, zr, adj_zl, adj_zr, found,
        p,u,v,r,i,k, sigma;
>>>>>>> 341d48f5 (Most recent working code)
  
  # check if D is a digraph

  if not IsSymmetricDigraph(D) then;
    Error("IsCograph: argument must be a symmetric digraph");
  fi;

# pick a vertex of G as the origin (choose first one)
# if a universal or isolated vertex, recurse on all other vertices without it (i.e. remove it)
  
  verts := DigraphVertices(D);
  P := [verts];

# a single vertex is a cograph
  if Length(verts) = 1 then
    return true;
  fi;

  if Length(verts) = 0 then
    return false;
  fi;

  origin := verts[1];
  adj := OutNeighboursOfVertex(D, origin);
  if Length(adj) = 0 or Length(adj) = Length(verts) - 1 then
    return IsCograph(InducedSubdigraph(D, Filtered(verts, v -> v <> origin)));
  fi;

# while there are non-singletons
# if a part of the partition is not a singleton part, then:
# find a non-singleton part
<<<<<<< HEAD
# MAKE A PARTITION P

  while not ForAll(P, part -> Length(part) = 1) do
    part := P[1];
      if Length(part) > 1 then
        # pick an arbitrary vertex from the part as pivot
          pivot := part[1];
          neighbours := OutNeighboursOfVertex(D, pivot);
          # split the part into N'\int part, origin, N\int part - set as unused parts
          refine := [Intersection(neighbours, part), [pivot], Intersection(part, Difference(verts, neighbours))];
          unused_parts := [Intersection(neighbours, part), Intersection(part, Difference(verts, neighbours)), Difference(P, [part])];
          used_parts := [];
# while there exist unused parts
# pick an arbitrary unused part and a vertex of the part
# set y as the pivot
# refine the parts of P using the pivot set N(y)

        while Length(unused_parts) > 0 do
          current_part := unused_parts[1];
          y := current_part[1];
          N_y := OutNeighboursOfVertex(D,y);
          refined_parts := [Intersection(N_y, current_part), [y], Difference(current_part, N_y)];
          
          Add(used_parts, current_part);
          Remove(unused_parts, 1);

          for p in refined_parts do
            if p not in used_parts then
              Add(unused_parts, p);
            fi;
          od;

          unused_parts_refined := [];
          for u in unused_parts do
            if u <> [] and u <> [y] then
              Add(unused_parts_refined, u);
            fi;
          od;

          unused_parts := unused_parts_refined;
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
    return false;
  fi;

  adj_zl := OutNeighboursOfVertex(D, zl);
  adj_zr := OutNeighboursOfVertex(D, zr);

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

return true;

=======

  while true do
    k := PositionProperty(P, part -> origin in part);
    if Length(P[k]) > 1 then
      part := Remove(P, k);
      # pick an arbitrary vertex from the part as pivot
      neighbours := OutNeighboursOfVertex(D, origin);
      # RULE 1
      # split the part into N'\int part, origin, N\int part - set as unused parts
      refine := [Intersection(neighbours, part), [origin], Difference(Intersection(part, Difference(verts, neighbours)), [origin])];
      unused_parts := [Intersection(neighbours, part), Intersection(part, Difference(verts, neighbours))];
      used_parts := [];
      unused_parts_refined := [];

      for r in refine do
        Add(P, r);
      od;
  # while there exist unused parts
  # pick an arbitrary unused part and a vertex of the part
  # set y as the pivot
  # refine the parts of P using the pivot set N(y)
      for u in unused_parts do
        if u <> [] then
          Add(unused_parts_refined, u);
        fi;
      od;
      unused_parts := ShallowCopy(unused_parts_refined);
  # RULE 2
      while Length(unused_parts) > 0 do
      
        current_part := unused_parts[1];
        y := current_part[1];
        N_y := OutNeighboursOfVertex(D,y);
        refined_parts := [Intersection(N_y, current_part), [y], Difference(current_part, N_y)];

        Add(used_parts, current_part);
        Remove(unused_parts, 1);

        unused_parts_refined := [];
        for u in unused_parts do
          if u <> [] and u <> [y] and not u in used_parts then
            Add(unused_parts_refined, u);
          fi;
        od;
        unused_parts := ShallowCopy(unused_parts_refined);
      od; 
    fi;

    # find nearest non-singleton parts to origin
    zl := PositionProperty(P, part -> Length(part) > 1 and Position(P, [origin]) > Position(P, part));
    zr := PositionProperty(P, part -> Length(part) > 1 and Position(P, [origin]) < Position(P, part));
    
    # if both fail, a singleton cannot be found, continue
    # if zr fails or zl and zr are adjacent, set orgin to zl
    # otherwise, either they are not adjacent or zl has failed. Set origin to zr
    if zl = fail or zr = fail then
      if zl = fail and zr = fail then
        break;
      elif zr = fail then 
        origin := P[zl][1];
      else
        origin := P[zr][1];
      fi;
      continue;
    fi;

    if (zl = zr + 1) or (zr = zl + 1) then
      origin := P[zl][1];
    else 
      origin := P[zr][1];
    fi;
  od;
 
  # Algorithm 5: Recognition Test
  # input: a permutation of the vertices
  # add vertices 0 and n+1
  sigma := [];
  for p in P do
    if Length(p) > 0 then
      Add(sigma, p[1]);
    fi;
  od;
  
  Add(sigma, 0);
  Add(sigma, Length(verts) + 1);
  
  # choose z to be the first vertex
  z := sigma[1];
  # succ(z) = vertex after z
  succ(z) := sigma[Position(sigma, z) + 1];
  # prec(z) = vertex before z
  # while z <> xn+1
  # if z and prec(z) are twins in The graph with permutation vetrex set
  # remove prec(z) from sigma
  # else, if z and succ(z) are twins in G(sigma) then
  # relabel z as succ(z) and remove prec(z) from sigma
  #else, z is succ(z)

  # if size(sigma with xo and xn+1 removed) = 1, then G is a cograph
  # else, G contains P4 and is not a cograph
>>>>>>> 341d48f5 (Most recent working code)
end;