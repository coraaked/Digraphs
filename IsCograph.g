IsCograph := function(D)
  local verts, P, origin, adj, part, neighbours, n_x,
        used_parts, unused_parts, unused_parts_refined,
        k, y, N_y, M, p, m, ma, x, l,
        zl, zr, prevorigin, new_P, t, current_part, s, zrpart, pivot,
        upd_part, zlpart, upd_m, pivotset;
  
    if not IsSymmetricDigraph(D) then;
    Error("IsCograph: argument must be a symmetric digraph");
    fi;
    
  # P = [V]
    verts := DigraphVertices(D);
    P := [verts];

    if Length(verts) = 1 then
        return true;
    fi;

    if Length(verts) = 0 then
        return false;
    fi;

# Choose vertex 1 as origin
    origin := verts[1];

  # if origin is isolated vertex or universal vertex, recurse on G - {origin}
    adj := OutNeighboursOfVertex(D, origin);
    if Length(adj) = 0 or Length(adj) = Length(verts) - 1 then
        return IsCograph(InducedSubdigraph(D, Filtered(verts, v -> v <> origin)));
    fi;

    pivot := ShallowCopy(origin);
    used_parts := [];
# while there are non singleton parts
    while ForAll(P, part -> Length(part) <= 1) = false do
    # if origin is not a singleton
        k := PositionProperty(P, part -> origin in part);
        if Length(P[k]) > 1 then
            part := Remove(P, k);
            neighbours := OutNeighboursOfVertex(D, origin);
            
            # find a better way of doing this step!
            upd_part := [Filtered(neighbours, p -> p in part), [origin], Difference(part, Union([origin], neighbours))];

            Add(used_parts, [origin]);
            
            unused_parts := [upd_part[1], upd_part[3]];
            
            part := ShallowCopy(upd_part);

            for p in upd_part do
                Add(P, p, k);
            od;
        fi;

    # Procedure 3
        new_P := ShallowCopy(Filtered(P, p -> p <> []));

        if ForAll(new_P, part -> Length(part) <= 1) = true then
         break;
        fi;

        while Length(Filtered(unused_parts, u -> u <> [])) > 0 do
            pivot := pivot + 1;

            M := [];

            s := PositionProperty(new_P, part -> pivot in part);
            current_part := ShallowCopy(new_P[s]);

            pivotset := OutNeighboursOfVertex(D, pivot); 

            for p in Difference(new_P, [current_part]) do
                if Intersection(p, pivotset) <> [] and Intersection(p, pivotset) <> p and Intersection(p, pivotset) <> [origin] then
                    k := ShallowCopy(Position(new_P, p));
                    Remove(new_P, k);
                    Add(M, p);
                fi;
            od;
    
# works up until here!

            if M <> [] then
                for m in M do
                    ma := Filtered(m, p -> p in pivotset);
                    upd_m := [ma, Difference(m, ma)];

                    for t in Filtered(upd_m, x -> x <> []) do
                        Add(new_P, t, k);
                    od;
# looking good up to here!
                    if m in unused_parts then
                        pos := ShallowCopy(Position(unused_parts, m));
                        Remove(unused_parts, pos);

                        if not ma in unused_parts and ma <> [] then
                            Add(unused_parts, ma);
                        fi;
                        
                        if not Difference(m, ma) in unused_parts and Difference(m,ma) <> [] then
                            Add(unused_parts, Difference(m, ma));
                        fi;

                    else
                        x := Minimum(m);
                        if x in upd_m[1] then
                            Add(unused_parts, upd_m[2]);
                        else
                            Add(unused_parts, upd_m[1]);
                        fi;
                    fi;

                    Add(used_parts, m);
                od;
            fi;
        
            if current_part in unused_parts then
                l := ShallowCopy(Position(unused_parts, current_part));
                Remove(unused_parts, l);
            fi;

            Add(used_parts, current_part);
            
        od;
        
        P := ShallowCopy(new_P);
        prevorigin := ShallowCopy(origin);

        zlpart := PositionProperty(P, part -> Length(part) > 1 and Position(P, [origin]) > Position(P, part));
        zrpart := PositionProperty(P, part -> Length(part) > 1 and Position(P, [origin]) < Position(P, part));

        if zlpart = fail or zrpart = fail then
            if zlpart = fail and zrpart = fail then
                continue;
            elif zrpart = fail then 
                zl := ShallowCopy(Minimum(P[zlpart]));
                origin := ShallowCopy(zl);
            else
                zr := ShallowCopy(Minimum(P[zrpart]));
                origin := ShallowCopy(zr);
            fi;
        else
            zl := ShallowCopy(Minimum(P[zlpart]));
            zr := ShallowCopy(Minimum(P[zrpart]));
            if zl in OutNeighboursOfVertex(D, zr) then
                origin := ShallowCopy(zl);
            else 
                origin := ShallowCopy(zr);
            fi;
        fi;

        P := Filtered(P,  i -> i <> [prevorigin]);
    
    od;
    
    return P;
end;

  # Algorithm 5: Recognition Test
  # input: a permutation of the vertices
  # add vertices 0 and n+1
  sigma := [0];
  for p in P do
    if Length(p) > 0 then
      Add(sigma, p[1]);
    fi;
  od;

  Add(sigma, Length(verts) + 1);
  
  # choose z to be the first vertex
  z := sigma[2];
  # succ(z) = vertex after z
  succz := sigma[Position(sigma, z) + 1];
  precz := sigma[Position(sigma, z) - 1];
  # prec(z) = vertex before z
  # while z <> xn+1
  while z <> sigma[Length(verts) + 1] do
  # if z and prec(z) are twins in The graph with permutation vetrex set
    N_z := OutNeighboursOfVertex(D, z);
    N_precz := OutNeighboursOfVertex(D, precz);
    N_succz := OutNeighboursOfVertex(D, succz);

# remove prec(z) from sigma
 # else, if z and succ(z) are twins in G(sigma) then
  # relabel z as succ(z) and remove prec(z) from sigma
  #else, z is succ(z)
    if N_z = N_precz or Union(N_z, [z]) = Union(N_precz, [precz]) then
      # relabel z as prec(z) and remove succ(z) from sigma
      Remove(sigma, Position(sigma, succz));
  
    elif N_z = N_succz or Union(N_z, [z]) = Union(N_succz, [succz]) then
      z := succz;
      Remove(sigma, Position(sigma, precz));
    else
      z := succz;
    fi;
  od;

 # if size(sigma with xo and xn+1 removed) = 1, then G is a cograph
# else, G contains P4 and is not a cograph
  if Length(Difference(sigma, [0, Length(verts)+1])) = 1 then
    return true;
  else
    return false;
  fi;
 
end;