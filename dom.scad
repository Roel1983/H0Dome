$fn=128;

r1 = 4;
r2 = 1.5;
rim1 = .5;
rim2 = .25;
r3= 7;
h=9;

profile1=[
    [1.5, 1],
    [1.6, .8],
    [2.2, .5],
    [2.2, .4],
    [1.6, .2],
    [1.5, 0]
];

profile2= concat(
    [
        for (a=[90:-360/$fn:45], 
             x=r1+r2-sin(a)*r2,
             y=r2-cos(a)*r2
        ) [x, y]
    ], [
        [r1+r2-sin(45)*r2 + rim1, r2-cos(45)*r2 - rim1],
        [r1+r2-sin(45)*r2 + rim1+rim2, r2-cos(45)*r2 - rim1+rim2],
        [r1+r2-sin(45)*r2 + rim1+2*rim2, r2-cos(45)*r2 - rim1],
        [r1+r2-sin(45)*r2 + rim1+2*rim2, -rim2],
    ]
);

loops = $fn;
function halfsphere_points(loops, r)= [
    for(loop=[0:loops-1], a1=loop/loops*360, a=[$fn/16:$fn/4],a2=a*360/$fn) [
        sin(a1) * sin(a2) * r,
        cos(a1) * sin(a2) * r,
        cos(a2) * r
    ]
];
     
function rotate_points(profile, loops)= [
    for(loop=[0:loops-1], a1=loop/loops*360, p2d=profile) [
        sin(a1) * p2d[0],
        cos(a1) * p2d[0],
        p2d[1]
    ]
];

function stack_points(points1, points2, loops)= [
    for(rings1 = len(points1) / loops,
        rings2 = len(points2) / loops,
        loop=[0:loops-1], 
        ring=[0:rings1 + rings2 -1]
    ) ring<rings1
        ? points1[loop * rings1 + ring]
        : points2[loop * rings2 + ring - (len(points1) / loops)]
];
    
function bend_points(points, r)= [
    for(p3d=points) [
        p3d[0],
        p3d[1],
        p3d[2] - r + sqrt(pow(r, 2) - pow(p3d[0], 2))
    ]
];
    
function translate_points(points, v)= [
    for(p3d=points) [
        p3d[0] + v[0],
        p3d[1] + v[1],
        p3d[2] + v[2],
    ]
];

solid(
    stack_points(
        translate_points(rotate_points(profile1, $fn), [0,0,h-r1*.07]),
        stack_points(
            translate_points(halfsphere_points(loops, r1), [0,0,h-r1]),
            bend_points(rotate_points(profile2, $fn), r3), 
            loops),
        loops),
    loops);

module solid(points, loops) {
    faces=concat(
        [for(rings = len(points) / loops,
            bi=[0:loops-1], ai=[0:rings-2]) [
            (ai + 0) + ((bi + 0) % loops) * rings,
            (ai + 1) + ((bi + 0) % loops) * rings,
            (ai + 1) + ((bi + 1) % loops) * rings,
            (ai + 0) + ((bi + 1) % loops) * rings,
        ]],
        [[for(rings = len(points) / loops, bi=[0:loops-1])
            bi * rings
        ]],
        [[for(rings = len(points) / loops, bi=[loops:-1:1])
            bi * rings - 1
        ]]
    );
    echo(faces);

    polyhedron(points= points, faces= faces);
}